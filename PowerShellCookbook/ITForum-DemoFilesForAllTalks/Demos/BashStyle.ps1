#COLOR=Yellow
#Requires -Version 1
# Bash-style script:
# - Don't need to declare parameters or variables
#COLOR=

function Myecho
{
#COLOR=RED
   for ($i = 0; $i -lt $args.count; $i++)
   {  "arg{0} = {1}" -f $i, $args[$i] 
#COLOR=
   }
}

#COLOR=Yellow
############ RUN IT #########################
#COLOR=
MyEcho This is a test

