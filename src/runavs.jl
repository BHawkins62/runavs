using Dates
using ConfParser

ini_file = "configs/config.ini"
regex = r"^\d{2}:\d{2}$"
home_dir = pwd()
time_to_run::String = ""


function convert_to_h_m(t_t_r)
    hour = parse(Int64, t_t_r[1:2])
    minute = parse(Int64, t_t_r[4:5])
    return hour, minute
end


function parse_ini()
    conf_var = ConfParse(ini_file);
    parse_conf!(conf_var);
    return conf_var
end


function run_avatars_sl(ch, avs, e_var)
    conf = parse_ini()
    password = ENV[retrieve(conf, "env", "env_key")]
    sldir = retrieve(conf, "dirs", "sl_dir")
    sldir = replace(sldir, "_"=>" ")
    cd(sldir)
    for (i, line) ∈ enumerate(avs)
        if i % 10 == 0 sleep(15) end 
        if (e_var == "false")
            avatar, password = line
            password = strip(password)     
        elseif ch == 3
            avatar = line[1]
        else
            avatar = line
        end   
        if occursin(" ", avatar)
            fname, lname = split(avatar, " ")
        else
            fname = avatar
            lname = "Resident"
        end        
        command = `SecondLifeViewer.exe --login $fname $lname $password`
        print_command = `SecondLifeViewer.exe --login $fname $lname xxxxxxxx`
        println("\n$print_command")
        run(command, wait=false)

    end
    println("\nWARNING: Do not exit this program prematurely, as exiting will also exit all avatars")
    cd(home_dir)
end

function run_avatars_rad(ch, avs, e_var)
    conf = parse_ini()
    password = ENV[retrieve(conf, "env", "env_key")]
    raddir = retrieve(conf, "dirs", "rad_dir")
    raddir = replace(raddir, "_"=>" ")
    cd(raddir)
    for (i, line) ∈ enumerate(avs)
        if i % 15 == 0 sleep(10) end
        if (e_var == "false")
            avatar, password = line
            password = strip(password)
        elseif ch == 4
            avatar = line[1]
        else
            avatar = line
        end
        if !(occursin(" ", avatar))
            avatar = avatar * " Resident"
        end
        command = `Radegast -u $avatar -p $password -a -g agni -l home --no-sound`
        print_command = `Radegast -u $avatar -p xxxxxxxx -a -g agni -l home --no-sound`
        println("\n$print_command")
        run(command, wait=false)
    end
    println("\nWARNING: Do not exit this program prematurely, as exiting will also exit all avatars")
    cd(home_dir)
end

function run_job(choice, avatars, e_var)
    if choice == 1 || choice == 3
        run_avatars_sl(choice, avatars, e_var)
    elseif choice == 2 || choice == 4
        run_avatars_rad(choice, avatars, e_var)
    end
end


function time_seq(hr_min,ans,avs,e_var)
    pending = true
    hour, minute = hr_min
    println("\nWill run job at: $(lpad(hour,2,"0")):$(lpad(minute,2,"0"))\n")
    while pending
        sleep(30)
        t = Dates.now()
        if (hour == Dates.hour(t)) && (minute == Dates.minute(t))
            run_job(ans, avs, e_var)
            pending = false
            break
        end
    end
end


function filename(e_var)
    while true
        println("Enter filename with .csv ending")
        if (e_var == "false")
            print("csv shall have two columns, one for the avatar names,")
            print(" and the other for the passwords: ") 
        else    
            print("csv file must be generated from a single column of avatar names: ")
        end
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
            line = split(line, ",")
            push!(avs, line)
        end
    end
    return avs
end

function input_names(e_var)
    avs = []
    if (e_var == "false")
        while true
            println("Enter Avatar Name and Password separated by a comma")
            print("Or Enter 0 to Quit Entering Avatars: ")
            avatar = split(readline(),",")
            if avatar[1] == ""
                continue
            elseif avatar[1] == "0"
                return avs
            else
                # println(avatar)
                push!(avs, avatar)
            end
        end
    else
        while true
            print("Enter Avatar Name or 0 to Quite Entering Names: ")
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
end


function choices(answr, time_run, e_var)
    avatars = []
    timed = time_run ≠ ""
    if timed
        hour_minute = convert_to_h_m(time_run)
    end
    if answr == 1 || answr == 2
        avatars = input_names(e_var)
        if timed
            time_seq(hour_minute, answr, avatars, e_var)
        else
            run_job(answr, avatars, e_var)
        end
    elseif answr == 3 || answr == 4
        fname = filename(e_var)
        avatars = read_names(fname)
        if answr == 3 && length(avatars) > 10
            println("Cannot load a file with more than 10 avatars for SL viewer!")
            println("Try using Radegast, or input avatars manually")
        elseif length(avatars) ≠ 0
            if timed
                time_seq(hour_minute, answr, avatars, e_var)
            else
                run_job(answr, avatars, e_var)
            end
        end
    end
end

0
function menu()
    input = nothing
    while input != 0
        println("\n1) Manual Entry for SL Viewer")
        println("2) Manual Entry for Radegast Viewer")
        println("3) Load CSV File for SL Viewer (max. 10 avatars)")
        println("4) Load CSV File for Radegast Viewer")
        print("Enter a Number (0 to Exit): ")
        try
            global input = parse(Int, readline())
            print("\n")           
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

function make_change()
    while true
        print("Y to change, N to not change: ")
        ch = uppercase(readline())
        if ch == "Y" || ch == "N"
            return ch
        else
            println("wrong character!\n")
        end
    end
end

function run_setup()
    conf = parse_ini()
    println("\n\n                  Runavs Setup                    ")
    println("__________________________________________________") 
    env1 = retrieve(conf, "env", "use_env");
    println("\ncurrent setting to use an environment variable: use_env = $env1")
    ans1 = make_change()
    if ans1 == "Y"
        if env1 == "false"
            use_env = "true"
        else
            use_env = "false"
        end
        commit!(conf, "env", "use_env", use_env);
    end

    env2 = retrieve(conf, "env", "env_key");
    println("\n\ncurrent key of the environment variable: env_key = $env2")
    ans2 = make_change()
    if ans2 == "Y"
        print("Enter the environment varible key you want to use: ")
        env_key = readline()
        commit!(conf, "env", "env_key", env_key);     
    end
    
    dir1 = retrieve(conf, "dirs", "sl_dir");
    dir1 = replace(dir1, "_"=>" ")
    println("\n\ncurrent directory for the secondlifeviewer.exe: sl_dir = $dir1")
    ans3 = make_change()
    if ans3 == "Y"
        println("Enter the directory where secondlifeviewer.exe")
        print("is located on your computer: ")
        sl_dir = readline()
        sl_dir = replace(sl_dir, " "=>"_")
        commit!(conf, "dirs", "sl_dir", sl_dir)
    end

    dir2 = retrieve(conf, "dirs", "rad_dir");
    dir2 = replace(dir2, "_"=>" ")
    println("\n\ncurrent directory for the radegast.exe viewer: rad_dir = $dir2")
    ans4 = make_change()
    if ans4 == "Y"
        println("Enter the directory where radegast.exe")
        print("is located on your computer: ")
        rad_dir = readline()
        rad_dir = replace(rad_dir, " "=>"_")
        commit!(conf, "dirs", "rad_dir", rad_dir)
    end

    if ans1 == "Y" || ans2 == "Y" || ans3 == "Y" || ans4 == "Y"
        println("\n\nYour proposed changes:")
        println("Use Environment Variable for Password: $(retrieve(conf, "env", "use_env"))")
        println("Environment Variable for Password: $(retrieve(conf, "env", "env_key"))")
        println("Your SecondLifeViewer Directory: $(retrieve(conf, "dirs", "sl_dir"))")
        println("Your Radegast Viewer Directory: $(retrieve(conf, "dirs", "rad_dir"))\n")
        print("\nEnter Y or N to save your changes: ")
        while true
            answer = uppercase(readline())
            if answer == "Y"
                save!(conf, ini_file);
                println("saved configuration changes")
                break    
            elseif answer == "N"
                println("config changes not saved as requesed")
                break
            else
                println("wrong character, try again with Y or N")
            end
        end
    end
end
        

function check_argument(arg)
    arg1::String = arg[1]
    if arg1 == "setup"
        return arg1
    elseif match(regex, arg1) ≠ nothing
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
        elseif time_to_run === "setup"
            run_setup()
            exit(0)
        end
    end
    conf = parse_ini()
    using_environment = retrieve(conf,"env", "use_env")
    answer = menu()
    if answer == 0
        println("Exiting program....")
        exit(0)
    else
        choices(answer, time_to_run, using_environment)
    end
end
