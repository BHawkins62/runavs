using Dates

regex = r"^\d{2}:\d{2}$"
password = ENV["SLP"]
home_dir = pwd()
time_to_run::String = ""


function convert_to_h_m(t_t_r)
    hour = parse(Int64, t_t_r[1:2])
    minute = parse(Int64, t_t_r[4:5])
    return hour, minute
end

function run_avatars_sl(avs)
    cd("C:/Program Files/SecondLifeViewer/")
    for (i, avatar) ∈ enumerate(avs)
        if i % 10 == 0
            sleep(15)
        end 
        if length(split(avatar)) == 1
            avatar = avatar * " Resident"
        end
        fname, lname = split(avatar)
        command = `SecondLifeViewer.exe --login $fname $lname $password`
        run(command, wait=false)
    end
    cd(home_dir)
end

function run_avatars_rad(avs)
    cd("C:/Program Files/Radegast/")
    for (i, avatar) ∈ enumerate(avs)
        if i % 15 == 0
            sleep(10)
        end 
        if length(split(avatar)) == 1
            avatar = avatar * " Resident"
        end
        command = `Radegast -u $avatar -p $password -a -g agni -l home --no-sound`
        run(command, wait=false)
    end
    cd(home_dir)
end

function run_job(choice, avatars)
    if choice == 1 || choice == 3
        run_avatars_sl(avatars)
    elseif choice == 2 || choice == 4
        run_avatars_rad(avatars)
    end
end


function time_seq(hr_min,ans,avs)
    pending = true
    hour, minute = hr_min
    println("\nWill run job at: $(lpad(hour,2,"0")):$(lpad(minute,2,"0"))\n")
    while pending
        sleep(30)
        t = Dates.now()
        if (hour == Dates.hour(t)) && (minute == Dates.minute(t))
            run_job(ans, avs)
            pending = false
            break
        end
    end
end


function filename()
    while true
        println("Enter filename with .csv ending")
        print("csv file must be generated from a single column of avatar names: ")
        fname = readline()
        if ! isfile(fname)
            folder = pwd();
            println("$fname does not exist, or is not in $folder.")
            println("please try again... or use Ctrl-C to exit")
            sleep(2)
            continue
        else
            return fname
        end
    end
end

function read_names(f)
    avs = []
    open(f) do csvfile
        for line ∈ eachline(csvfile)
            push!(avs, line)
        end
    end
    return avs
end

function input_names()
    avs = []
    while true
        print("Enter Avatar Name or 0 to Quit Entering Names: ")
        name = readline()
        if name == ""
            continue
        elseif name == "0"
            return avs
        else
            push!(avs, name)
        end
    end
end


function choices(answr, time_run)
    avatars = []
    timed = time_run ≠ ""
    if timed
        hour_minute = convert_to_h_m(time_run)
    end
    if answr == 1 || answr == 2
        avatars = input_names()
        if timed
            time_seq(hour_minute, answr, avatars)
        else
            run_job(answr, avatars)
        end
    elseif answr == 3 || answr == 4
        fname = filename()
        avatars = read_names(fname)
        if answr == 3 && length(avatars) > 10
            println("Cannot load a file with more than 10 avatars for SL viewer!")
            println("Try using Radegast, or input avatars manually")
        elseif length(avatars) ≠ 0
            if timed
                time_seq(hour_minute, answr, avatars)
            else
                run_job(answr, avatars)
            end
        end
    end
end


function menu()
    input = nothing
    while input != 0
        println("\n1) Manual Entry for SL Viewer")
        println("2) Manual Entry for Radegast Viewer")
        println("3) Load CSV File for SL Viewer (max. 10 avatars")
        println("4) Load CSV File for Radegast Viewer")
        print("Enter a Number (0 to Exit): ")
        try
            global input = parse(Int, readline())           
            if input < 0 || input > 4
                println("\nLooks like you entered an incorrect number!")
                continue
            else
                return input
            end
        catch err
            println("\nInvalid character error!,\nPlease enter a number only")
            continue
        end 
    end
end

function check_argument(arg)
    arg1::String = arg[1]
    if match(regex, arg1) ≠ nothing
        return arg1
    else
        println("\n Command-line argument was not in correct format!")
        println("Use you local time: 24 hour format xx:xx")
        println("include leading zero if required. (e.g. 09:30)\n")
        return nothing
    end
end


while true
    if length(ARGS) > 0
        global time_to_run = check_argument(ARGS)
        if time_to_run === nothing
            println("Exiting program - Try Again.")
            exit(0)
        end
    end
    answer = menu()
    if answer == 0
        println("Exiting program....")
        exit(0)
    else
        choices(answer, time_to_run)
    end
end
