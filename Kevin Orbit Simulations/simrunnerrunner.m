function result = simrunnerrunner()

for n = 1:9
    result{n} = simrunner(-(10*n), (10*n), n+12);
end