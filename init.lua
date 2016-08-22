executable = "user.lua"
files = file.list()
for key, value in pairs(files) do
    if key == executable then
        print("Executing user script in 5 seconds")
        tmr.alarm(0, 5000, 0, function()
            print("Executing ".. executable)
            dofile(executable)
        end)
    end
end
