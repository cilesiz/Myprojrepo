#!/usr/bin/perl

#=================
# Pragmas
#=================
use strict;
# The strict pragma checks for unsafe programming constructs. Strict forces 
# a programmer to declare all variables as package or lexically scoped variables. 
# Strict also forces specific syntax with sub, forcing the programmer to call 
# each subroutine explicitly. The programmer also needs to use quotes around all 
# strings, and to call each subroutine explicitly, which forces a distrust of bare words.

use warnings;
# The warnings pragma sends warnings when the Perl compiler detects a possible 
# typographical error and looks for potential problems. There are a number of 
# possible warnings, but warnings mainly look for the most common syntax mistakes 
# and common scripting bugs.

#=================
# Modules
#=================
use Getopt::Long;
# The Getopt::Long module implements an extended getopt function called GetOptions(). 
# This function adheres to the POSIX syntax for command line options, with GNU extensions. 
# In general, this means that options have long names instead of single letters, and are 
# introduced with a double dash "--". Support for bundling of command line options, as was 
# the case with the more traditional single-letter approach, is provided but not enabled by default.

#=================
# Define vars
#=================
my $DEBUG;
my $COMMAND_TIMEOUT;
my $debug_properties_file;
my $actions_properties_file;
my $servers_properties_file;
my $timeout_properties_file;

my @TPCR_SERVER_LIST;
my $TPCR_ACTIVE_SERVER;

my $opt_tpcr_client;
my $TPCR_CLIENT; 

my @ERROR_MSG;

my $opt_session;
my $opt_session_name; 
my $session;

my $opt_action;
my $action;

my $WINDOWS = 0; 

GetOptions(	"action=s" => \$opt_action, 
		"tpcr_client=s" => \$opt_tpcr_client,
		"session=s" => \$opt_session,
		"session_name=s" => \$opt_session_name
	  );

my @valid_actions;

my $status_file;
my $session_properties_file;

my $tpcr_user_home;
if ( defined $ENV{HOME} ) {
	# We are on a Linux or UNIX server
	$WINDOWS = 0;
	$tpcr_user_home = $ENV{HOME};
	$status_file="$tpcr_user_home/tpcr-cli/status.log";
	$session_properties_file="$tpcr_user_home/tpcr-cli/session.properties";
	$debug_properties_file="/opt/storage_tools/csmscripts/cli_script/debug.properties";
	$actions_properties_file="/opt/storage_tools/csmscripts/cli_script/actions.properties";
	$servers_properties_file="/opt/storage_tools/csmscripts/cli_script/servers.properties";
	$timeout_properties_file="/opt/storage_tools/csmscripts/cli_script/timeout.properties";
	$TPCR_CLIENT="/opt/storage_tools/csmcli/csmcli.sh";
} elsif ( defined $ENV{userprofile} ) {
	# We are on a Windows server
	$WINDOWS = 1;
	$tpcr_user_home = $ENV{userprofile};
	$status_file="$tpcr_user_home\\tpcr-cli\\status.log";
        $session_properties_file="$tpcr_user_home\\tpcr-cli\\session.properties";
	$debug_properties_file="c:\\storage_tools\\csmscripts\\cli_script\\debug.properties";
	$actions_properties_file="\\storage_tools\\csmscripts\\cli_script\\actions.properties";
        $servers_properties_file="\\storage_tools\\csmscripts\\cli_script\\servers.properties";
	$timeout_properties_file="\\storage_tools\\csmscripts\\cli_script\\timeout.properties";
	$TPCR_CLIENT="\\storage_tools\\csmcli\\csmcli.bat";
} else {
	print "tpcr_action.pl ERROR: Unable to determine TPC-R user home directory, exiting...";
	exit 9;
}

#=================
# Define Subs
#=================

sub DetermineActiveTPCR() {
  # This subroutine uses the servers listed in the properties file 
  # and goes down the list attempting to login.  Once a login is 
  # successful the lshaservers command is run to determine what the active
  # server is.

  my $AVAILABLE_SERVER;

  ACTIVE_CHECK:foreach my $SERVER (@TPCR_SERVER_LIST) {
	print "\n[DEBUG]->Contacting TPC-R server $SERVER ...\n" if ($DEBUG);
	my $lshaservers = &DelimToHash($SERVER,'lshaservers');
	if ($lshaservers){
		foreach my $lshaservers_num (sort keys %$lshaservers) {
		 if ($lshaservers->{$lshaservers_num}->{'Role'}){
        	   if ($lshaservers->{$lshaservers_num}->{'Role'} eq "ACTIVE"){
			$AVAILABLE_SERVER = $lshaservers->{$lshaservers_num}->{'Server'};
			print "[DEBUG]->Found active server: $AVAILABLE_SERVER\n" if ($DEBUG);
			last ACTIVE_CHECK;
		   }
		 }
		}
	}else{
		print "[DEBUG]->Unable to get HA server list from $SERVER\n" if ($DEBUG);
	}
  }
  
  if (!$AVAILABLE_SERVER) {
	print "\n[DEBUG]->Error Message = @ERROR_MSG\n" if ($DEBUG);
	if ( grep {"Login failed"} @ERROR_MSG ) {
		print "tpcr_action.pl ERROR: Invalid password for TPC-R account OR invalid TPC-R server name OR TPC-R servers are unreachable on the network\n";
	} else { 
		print "tpcr_action.pl ERROR: Unable to find an ACTIVE TPC-R server - @ERROR_MSG\n";
	}
	exit 10; 
  }
  return $AVAILABLE_SERVER;
}

sub TalkToTPCR() {
   # This subroutine handles the connection to the TPC-R server
   # It will connect to the server and run the given command.
   
   my $SERVER = shift;	  # The active TPC-R server to talk to
   my $COMMAND = shift;   # The command to run 
   my $ARGUMENT = shift;  # Arguments/options for the command
   my $NODELIM = shift;   # Option to turn off colon delimited data from TPC-R 

   my @info;		  # The information returned from the TPC-R server
   my $TPCR_CLI;	  # The validated TPC-R client program with arguments
   my $CMD;		  # The full CLI command to invoke the TPC-R client
   my $RETRIES = 3;	  # Number of retires to attempt 
   my $TPCR_CLIENT_ARGS = " -noinfo -server $SERVER ";
   my $exitcode = 254;

   if ( $ARGUMENT ne ''){
	$ARGUMENT = "\"" . "$ARGUMENT" . "\"";
   }
   
   if (-e $TPCR_CLIENT ) {
      $TPCR_CLI = sprintf('%s %s ',$TPCR_CLIENT,$TPCR_CLIENT_ARGS);
   } else {
      die ("tpcr_action.pl ERROR: Unknown TPC-R Client [$TPCR_CLIENT]\n");
   }

   if ($NODELIM) {
      $CMD = "$TPCR_CLI $COMMAND $ARGUMENT\n";
   } else {
      $CMD = "$TPCR_CLI $COMMAND -fmt delim -delim : $ARGUMENT\n";
   }
   print "[DEBUG]->Running $CMD" if ($DEBUG);
   
   while ($RETRIES > 0){
	eval {
      		local $SIG{ALRM} = sub { die "Command Timeout\n"};
   		alarm $COMMAND_TIMEOUT; # Set time to wait for command to complete
      		if ($WINDOWS) {
			print "[DEBUG]->WINDOWS flag is set\n" if ($DEBUG);
			@info = `$CMD && exit /b ERRORLEVEL`; # Attempt command
		} else {
			@info = `$CMD`; # Attempt command	
		}
		$exitcode = $? >>8; # Get exitcode if we returned from command
      		alarm 0; # Clear alarm
   	};
	print "[DEBUG]->exitcode = $exitcode\n" if ($DEBUG);
	if ($exitcode == 0){
	     print "[DEBUG]->Connection established...\n" if ($DEBUG);
	     $RETRIES = -1;
	} else {
	     print "\n[DEBUG]->TPC-R connection not available\n" if ($DEBUG);
	     print "[DEBUG]->Command = $CMD"  if ($DEBUG);
	     print "[DEBUG]->Returned = @info\n" if ($DEBUG);
	     if ( $ERROR_MSG[-1] ){
	     	if ( "$ERROR_MSG[-1]" ne "@info" ){
	     	   push(@ERROR_MSG, @info);
		}
	     }else{
		push(@ERROR_MSG, @info);
	     }
	     sleep 3;
	}

      	$RETRIES--;
   }
   
   if ($RETRIES == 0){
      print "[DEBUG]->Unable to contact TPC-R server $SERVER\n" if ($DEBUG);
   }
   
   if ($DEBUG == 2) {
      foreach  (@info){
	     chomp $_;
         print "Got [$_]\n"; 
      }
   }

	return @info;
}

sub check_input {
	# This subroutine checks the user input (command line argument)
	# It will reject input that contains characters outside of the allowed
	# Mainly used to restirct delimeters from being passed on to the TPC-R client

        my $user_input = $_[0];         # First parameter is the user input to check
        my $input_name = $_[1];         # Second parameter is the name of the input - used for the error message

        # Limit input to 128 chars
        unless ( $user_input =~ /(.{1,128})/ ) {
                print "\ntpcr_action.pl ERROR: $input_name is too long\n";
                exit 1;
        }

        # Limit input to alphabetics, numerics, underscores, hyphens, colons , at signs, and dots
        if  ( $user_input =~ /^([-\:\@\w.]+)$/ ) {
                $user_input = $1;
        } else {
                print "\ntpcr_action.pl ERROR: $input_name contains invalid characters\n";
                exit 2;
        }

        # Convert to lower case
        $user_input = lc ($user_input);

        return $user_input;
}

sub read_properties_file {
	# This subroutine loads the contents of a properties file.  
	# All proprites files are one entry per line.  
	# Lines that begin with a pound sign # are ignored.
	# It returns an array that contains the contents of the file passed as the only parameter.

	my $FILENAME = shift;	# First parameter is the full path to the properties file
	my @file;               # The raw contents of of the properties file
	my @valid_properties;   # The array of valid properties that we create from the properties file

	# Read in the config file	
	if ( open(FILE,"<$FILENAME") ) {
        	@file = <FILE>;
        	close (FILE);

        	# Remove any comments
        	@file = grep {!/^#/} @file;

		# Remove any blank lines
		 @file = grep {!/^\n/} @file;

		foreach my $line (@file) {
                        #$line = lc($line);
                        chomp($line);
                        push ( @valid_properties, $line);
                }

	} else {
        	print "\ntpcr_action.pl ERROR: Can not open the properties file $FILENAME!\n";
        	exit 3;
        }

	if ($#valid_properties == 0){
		return $valid_properties[0];
	}else{
		return @valid_properties; 
	}
}

sub DelimToHash() {
   # This subroutine takes the output of a command and breakes it up
   # into a perl hash.  Used for delimeted output of name-value pairs.
	
   my $SERVER = shift;  	# Server to run command on
   my $COMMAND = shift;		# Command to run
   my $ARGUMENT = shift;	# Arguments to the command
   my $NODELIM = shift;		# Option to turn of delimeted output
   my $MULTILINE = shift;	# Option to treat command output as a multi-line listing, not table format.  Must be used
				# with delimiters.
   
   my %hash;
   my @heading;

   if (! defined($ARGUMENT)){
	$ARGUMENT = "";
   }

   my @details = &TalkToTPCR($SERVER,$COMMAND,"$ARGUMENT",$NODELIM);

      print "[DEBUG]->$COMMAND: Got [",join('|',@details)."]\n" if ($DEBUG == 2);

      my $linenum = 0;
      foreach (@details) {
      	print "[DEBUG]->$linenum, $_" if ($DEBUG == 2);
         
	if ($MULTILINE) {
		print "[DEBUG]->MultiLine" if ($DEBUG == 2);
		my ($key,$value) = split(':',$_);
		$key =~ s/^\s+|\s+$//g;  # Remove both leading and trailing whitespace
		$value =~ s/^\s+|\s+$//g;  # Remove both leading and trailing whitespace
		chomp($value); # Remove return from end of line
		if ( $value eq '') {
			$value = '-';
		}
		$hash{$key} = $value;
	} else {
		if ($linenum == 0) {
              		@heading = split(':',$_);
            	} else {
               		my @line = split(':',$_);
	       		if ($line[0] =~ /=============/) {
               		   next;	# Dump format line 
	       		}
               		my $counter = 0;
               		foreach my $key (@heading) {
				$key =~ s/^\s+|\s+$//g;  # Remove both leading and trailing whitespace
			      	my $value = $line[$counter];
			      	$value =~ s/^\s+|\s+$//g;  # Remove both leading and trailing whitespace
			      	if ( $value eq '') {
			           $value = '-';
			      	}
               			printf("\n[DEBUG]->$COMMAND: LINE [%i], KEY [%s], VALUE [%s]\n",$linenum,$key,$value) if ($DEBUG == 2);         
               			$hash{$linenum}{$key} = $value;
			   	$counter++;
               		}	
		}	
         }
         $linenum++;
      } 
      return \%hash;
}


#========
# Main
#========

# Read in the debug properties file
$DEBUG = read_properties_file($debug_properties_file);

# Read in the TPC-R client timeout properties file
$COMMAND_TIMEOUT = read_properties_file($timeout_properties_file);
print "[DEBUG]->Command Timeout = $COMMAND_TIMEOUT\n" if $DEBUG;

# Show the TPC-R user home directory if debug is on
print "[DEBUG]->TPC-R user home directory = $tpcr_user_home\n" if $DEBUG;

# Check for the command line arg "action"
if ( defined($opt_action) ) {
    $action = check_input($opt_action,"TPC-R action");
} else {
    print "\ntpcr_action.pl ERROR: No ACTION given.\n";
    exit 4;
}

# Check for the command line arg "tpcr_client"
if ( defined($opt_tpcr_client)) {
    $TPCR_CLIENT = $opt_tpcr_client;
    print "\n[DEBUG]->TPC-R client option defined.  Overriding default client\n" if $DEBUG;
} else {
    print "\n[DEBUG]->No TPC-R client given.  Using default client.\n" if $DEBUG;
}


# Read in the actions properties file
@valid_actions = read_properties_file($actions_properties_file);

# Check if the command line action matches a valid action
if ( !grep {/^$action$/} @valid_actions){
        print "\ntpcr_action.pl ERROR: ACTION given does not match valid action list.  Exiting.\n";
        exit 5;
}

# Read in the TPC-R server properties file
@TPCR_SERVER_LIST = read_properties_file($servers_properties_file);

# Figure out the TPC-R session name
if ( defined($opt_session_name) ) {
	$session = $opt_session_name;
} elsif (defined($opt_session) ) {
	my %session_hash;
	my @session = read_properties_file($session_properties_file);
	foreach (@session) {
		my ($key,$value) = split(':',$_);
		$key =~ s/^\s+|\s+$//g;  # Remove both leading and trailing whitespace
        	$value =~ s/^\s+|\s+$//g;  # Remove both leading and trailing whitespace
        	chomp($value); # Remove return from end of line
        	if ( $value eq '') {
        	   $value = '-';
        	}
        	$session_hash{$key} = $value;
	}
	if (defined($session_hash{$opt_session})) {
		$session = $session_hash{$opt_session};
	} else {
		print "\ntpcr_action.pl ERROR: No TPC-R session match found for $opt_session.  Exiting.\n";
        	exit 6;
	}
} elsif ( ($action  ne "test_conn" ) && ($action ne "get_webserver") ) {
	print "\ntpcr_action.pl ERROR: No TPC-R session given.  Exiting.\n";
    	exit 7;
}

# Figure out which TPC-R server is available and active
$TPCR_ACTIVE_SERVER = DetermineActiveTPCR;

my @cmdsess;
if ( $action eq "test_conn" ){
	$action = "whoami";
	print "\n[DEBUG]->Performing action **- $action -** \n" if ($DEBUG);
	# Perform the command and get the output, substitute TPC-R command for 'action' from the command line
	@cmdsess = &TalkToTPCR($TPCR_ACTIVE_SERVER,"$action", "",'nodelim'); 
} elsif ( $action eq "get_status" ) {
	$action = "lsrolepairs -l -hdr off -fmt delim -delim ,";
	print "\n[DEBUG]->Performing action **- $action -** on session $session \n" if ($DEBUG);
	# Perform the command and get the output, substitute TPC-R command for 'action' from the command line
	@cmdsess = &TalkToTPCR($TPCR_ACTIVE_SERVER,"$action", "$session",'nodelim'); 
} elsif ( $action eq "get_activehost" ) {
	$action = "showsess";
        print "\n[DEBUG]->Performing action **- $action -** on session $session \n" if ($DEBUG);
        # Perform the command and get the output, substitute TPC-R command for 'action' from the command line
        @cmdsess = &TalkToTPCR($TPCR_ACTIVE_SERVER,"$action", "$session",'nodelim');
	# Massage the result to get what we want 
	@cmdsess = grep(/Active Host/, @cmdsess);
	@cmdsess = (split/Active Host/,$cmdsess[0]);
} elsif ( $action eq "get_state" ) {
        $action = "showsess";
        print "\n[DEBUG]->Performing action **- $action -** on session $session \n" if ($DEBUG);
        # Perform the command and get the output, substitute TPC-R command for 'action' from the command line
        @cmdsess = &TalkToTPCR($TPCR_ACTIVE_SERVER,"$action", "$session",'nodelim');
	if ( @cmdsess <= 1 ) {
		print "tpcr_action.pl ERROR: Session $session name not found on TPC-R server\n";
		exit 8;
	}
        # Massage the result to get what we want
        @cmdsess = grep(/State/, @cmdsess);
        @cmdsess = (split/State/,$cmdsess[0]);
} elsif ( $action eq "get_webserver" ) {
	print "\n[DEBUG]->Performing action **- $action -** \n" if ($DEBUG);
	# Output the host package download URL of the active TPC-R server   
	print "http://" . "$TPCR_ACTIVE_SERVER" . ":81/";
} else {
	print "\n[DEBUG]->Performing action **- $action -** on session $session \n" if ($DEBUG);
	# Perform the command and get the output, use 'action' verbatim  from command line with the cmdsess TPC-R command
	@cmdsess = &TalkToTPCR($TPCR_ACTIVE_SERVER,"cmdsess -quiet -action $action", "$session",'nodelim'); 
}

my $cmdsess = "@cmdsess"; 	# Convert array to string
$cmdsess =~  s/^\s+|\s+$//g; 	# Remove leading and trailing white space
print "$cmdsess\n";		# Output result from TPC-R server

if (-e $status_file ) {
	print "\n[DEBUG]->Found existing status file\n" if ($DEBUG);
	open STATUS_FILE, ">>$status_file" || die("Cannot Open Status File");
} else {
	print "\n[DEBUG]->No existing status file\n" if ($DEBUG);
	open STATUS_FILE, ">$status_file" || die("Cannot Open Status File");
}
print STATUS_FILE "$cmdsess\n";
close STATUS_FILE;

