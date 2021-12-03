/*
 * Copyright (C)2010 Jacques H. de Villiers <Jacques@deVilliers.com>
 * Copyright (C)2010 Center for Spoken Language Understanding
 *                   Oregon Health & Science University
 *
 *----------------------------------------------------------------------------
 * Binary Typing Language Model client interface
 * Simplified API for Brian Roark's client/server code
 *----------------------------------------------------------------------------
 */

#ifndef BTLM_H
#define BTLM_H

#include <limits.h>

#define BTLM_VERSION_MAJOR 1
#define BTLM_VERSION_MINOR 4
#define BTLM_VERSION_PATCH 0

/* This is the main BTLM connection handle, initialized by BTLM_Init*()
 *  and used to provide context to the BTLM library functions.
 */
typedef struct BTLM_ *BTLM;


/* These BTLM_Init*() flags change the error behaviour of the library.
 * The default is for the majority of BTLM functions to return an BTLM_Result
 * code to indicate success or failure.
 * Upon a non-BTLM_OK return code, the flags modify the library behaviour
 * as follows:
 *  BTLM_PRINT_ON_ERROR: Print a human-readable error message to stderr
 *  BTLM_ABORT_ON_ERROR: call abort() to terminate the process
 *  BTLM_EXIT_ON_ERROR:  call exit() to terminate the process
 * BTLM_ABORT_ON_ERROR takes priority over BTLM_EXIT_ON_ERROR.
 */
typedef enum {
  BTLM_PRINT_ON_ERROR=1<<0,
  BTLM_ABORT_ON_ERROR=1<<1,
  BTLM_EXIT_ON_ERROR =1<<2,
} BTLM_Flags;


/* Return codes, BTLM_OK indicates success, anything else is a failure
 */
typedef enum {
  BTLM_OK, BTLM_ERROR,
  BTLM_MALLOC, BTLM_BADFILENAME, BTLM_BADSTATEID, BTLM_BADSYMBOL,
  BTLM_BADSOURCE, BTLM_ACCESS, BTLM_CONNECTION, BTLM_BADPACKET,
  BTLM_BUFFTOOSMALL,BTLM_SOCKET, BTLM_SOCKOPT,
  BTLM_BADPORT, BTLM_BADHOSTNAME, BTLM_BADOPCODE,
  BTLM_BADOPCODEARGS, BTLM_BADTYPE, BTLM_VERSIONMISMATCH,
  BTLM_WINSOCK,
  BTLM_RESULT_MAX
} BTLM_Result;


/* Initialization type
 */
typedef enum {
  BTLM_INIT_LOCAL, BTLM_INIT_REMOTE, BTLM_INIT_SHARED
} BTLM_Init;


/* Convenience macros
 */
#define BTLM_IsLocal(h) (BTLM_InitType(h)==BTLM_INIT_LOCAL)
#define BTLM_IsRemote(h) (BTLM_InitType(h)==BTLM_INIT_REMOTE)
#define BTLM_IsShared(h) (BTLM_InitType(h)==BTLM_INIT_SHARED)


/* Initialize the BTLM library with an in-process language model.
 *
 *  A BTLM_Init*() function must be called before any other library function.
 *    filename - in: path to a compact model file
 *      flags  - in: modify BTLM library error behaviour
 *      handle - out: new BTLM connection handle.
 */
BTLM_Result BTLM_InitLocal(const char *filename,
			   BTLM_Flags flags, BTLM *handle);


/* Initialize the BTLM library and connect to a remote BTLM server.
 *
 *  A BTLM_Init*() function must be called before any other library function.
 *    host   - in: remote server host name, or NULL for the default
 *    port   - in: remote server port number, or NULL for the default
 *    pass   - in: remote server password, or NULL for the default
 *    flags  - in: modify BTLM library error behaviour
 *    handle - out: new BTLM connection handle.
 */
BTLM_Result BTLM_InitRemote(const char *host, const char *port,
			    const char *pass,
			    BTLM_Flags flags, BTLM *handle);


/* Initialize the BTLM library with a shared in-process language model.
 *
 *  A BTLM_Init*() function must be called before any other library function.
 *      source - in: existing BTLM handle, as returned by BTLM_InitLocal()
 *      flags  - in: modify BTLM library error behaviour
 *      handle - out: new BTLM connection handle.
 */
BTLM_Result BTLM_InitShared(BTLM source,
			    BTLM_Flags flags, BTLM *handle);


/* Return the handle type:
 *  BTLM_INIT_LOCAL   - in-process, handle returned by BTLM_InitLocal()
 *  BTLM_INIT_REMOTE  - remote server, handle returned by BTLM_InitRemote()
 *  BTLM_INIT_SHARED  - in-process with a shared language model, as returned
 *                        by BTLM_InitShared()
 */
BTLM_Init BTLM_InitType(BTLM handle);


/* Allocate a new state
 *   handle   - in: BTLM library handle
 *   K, P     - in: language model parameters
 *   newState - out: ID of newly allocated state
 */
BTLM_Result BTLM_Alloc(BTLM handle, double K, double P, int *newState);


/* Close an BTLM library handle, dellocates all associated resources
 *  handle - in: BTLM library handle
 *
 *  Calling BTLM_Close() on a handle that was allocated by:
 *    - BTLM_InitLocal() will free all in-process memory allocated to
 *       the language model and the library handle.
 *    - BTLM_InitRemote() will free the library handle and close the remote
 *       connection to the BTLM server.
 *    - BTLM_InitShared() will free the library handle.
 *
 *  Do not call BTLM_Close() on a handle used as source argument
 *   to BTLM_InitShared() until all shared handles that reference it have been
 *   closed.
 */
BTLM_Result BTLM_Close(BTLM handle);


/* Return a short human-readable description of the result code
 *  result - BTLM_Result return code
 */
const char *BTLM_ErrorMsg(BTLM_Result result);


/* Return an array of probabilities for each symbol
 *  handle - in: BTLM library handle
 *  state  - in: language model state
 *  lprobs - out: -log(prob(symbol[i])) where 0<=i<N
 *                N is the number of symbols, as returned by BTLM_GetSymbols()
 *  lprobs must point to an existing array of double, with at least N slots
 *   allocated.
 */
BTLM_Result BTLM_GetLogProbs(BTLM handle, int state, double *lprobs);


/* Return the name of the model
 *  handle - in: BTLM library handle
 *  model  - out: model name
 *            this is the filename passed to BTLM_InitLocal()
 *            or the filename the remote BTLM server was started with.
 *
 * The returned model value points to memory managed by the BTLM library;
 *  model must not be malloced() or free()d by the caller
 */
BTLM_Result BTLM_GetModelName(BTLM handle, const char **model);


/* Return a sorted list of symbol indices.
 *  handle - in: BTLM library handle
 *  state  - in: language model state
 *  index - out: symbol indices in order of descending probability
 *                
 *  index must point to an existing array of int, with at least N slots
 *   allocated.  N is the number of symbols, as returned by BTLM_GetSymbols()
 */
BTLM_Result BTLM_GetSortedIndices(BTLM handle, int state, int *index);


/* Return an ordered array of symbols used in this language model
 *  handle  - in: BTLM library handle
 *  num     - out: number of symbols in this model
 *  symbols - out: array of symbol strings
 *
 * The num and symbols parameters may be NULL.
 * The returned symbols value points to memory managed by the BTLM library;
 *  symbols must not be malloc()ed or free()d by the caller.
 */
BTLM_Result BTLM_GetSymbols(BTLM handle, int *num, const char **symbols[]);


/* Reset the BTLM library
 *  handle  - in: BTLM library handle
 *
 * The state (and memory allocations) accumulated for this handle will be
 *  discarded.  This is logically equivalent to calling BTLM_Close() followed
 *  by another BTLM_Init*(), but avoids some of the additional ovearhead that
 *  would incur.
 */
BTLM_Result BTLM_Reset(BTLM handle);


/* Shut down the server
 *  handle - in: BTLM library handle, as returned by BTLM_InitRemote()
 *
 * Calling this function will stop the remote BTLM server from accepting
 *  new connections.  It will terminate when the last client connection
 *  is closed.
 */
BTLM_Result BTLM_Shutdown(BTLM handle);


/* update_state_client() */
/* are those K and P parameters really used anywhere in Brian's code?
 * Use NULL for return pointers that you're not interested in.
 */
/* Update language model state
 *  handle  - in: BTLM library handle
 *  state   - in: current state (as returned by BTLM_Alloc() or BTLM_Update())
 *  symbol  - in: selected symbol index, 0<=symbol<N, where N is the number of
 *               symbols, as returned by BTLM_Symbols()
 *  newState - out: newly allocated state ID.
 *  K, P     - out: model parameters.
 *
 *  newState, K and P may be NULL, in which case these values are discarded.
 */
BTLM_Result BTLM_Update(BTLM handle, int state, int symbol,
			int *newState, double *K, double *P);


#endif


/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 2
 * fill-column: 78
 * End:
 */
