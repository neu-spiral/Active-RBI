>> l = lm('192.168.99.100')

l = 

  lm with properties:

    symbol: ''

>> l.update('h')
>> l.update('e')
>> l.update('l')
>> l.probs

ans =

    5.0221
   12.1930
   17.7848
    3.6852
    5.1813
    1.5084
   10.6852
   22.6246
    5.5231
   19.2526
    9.5690
    0.9703
    1.3971
   17.1481
    5.9977
    2.2750
    9.4928
   26.0641
    5.3385
   11.2692
   25.4059
   36.2672
   15.7838
   14.2281
    8.8737
    7.1842

>> sum(exp(-ans))

ans =

    1.0000

>> l.update('l')
>> logprob = l.probs

logprob =

    2.9140
   20.5400
   13.1406
   17.2353
    1.6279
   19.7978
   17.9326
   23.8105
    2.0547
   33.5869
   14.0830
    8.6133
   19.7451
   19.0615
    0.6631
   22.0205
   16.8144
   22.9970
    2.3760
   22.9502
   30.0781
   26.3271
   23.4248
   42.5176
    4.3515
   13.5527

>> l.history

ans = 

    'h'
    'e'
    'l'
    'l'

>> l.undo
>> l.probs

ans =

    5.0221
   12.1930
   17.7848
    3.6852
    5.1813
    1.5084
   10.6852
   22.6246
    5.5231
   19.2526
    9.5690
    0.9703
    1.3971
   17.1481
    5.9977
    2.2750
    9.4928
   26.0641
    5.3385
   11.2692
   25.4059
   36.2672
   15.7838
   14.2281
    8.8737
    7.1842

>> l.history

ans = 

    'h'
    'e'
    'l'