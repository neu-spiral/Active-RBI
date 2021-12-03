
docker-machine start default

FOR /f "tokens=*" %%i IN ('docker-machine env --shell cmd default') DO %%i

docker run -d -p 5000:5000 -v /c/Users/Paula/Documents/langModelFile/nyt-giga.n6.wb.k3.fst:/opt/lm/nyt.fst lmimage python server.py
