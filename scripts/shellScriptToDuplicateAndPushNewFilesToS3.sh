#!/bin/bash
# created for WGBH for use the its Media Library and Archives
# by Kevin Carter, 2019-07-16

export endpointURL='https://s3.us-east-1.amazonaws.com' ;
export bucketName='americanarchive.org' ;

export profileName='transcript-editor-script'   # personalize this for your own use to avoid subsequent dialogs/prompts for the profile;
export profileNameList=$(grep '\[' "$HOME/.aws/config" | tr -d '\[\]') ;
export profileNameCount=$(echo "$profileNameList" | wc -l | tr -dC '[0-9]') ;

function usage {
clear ;
echo "$1" ;
echo ;
echo ;
echo "Usage: " ;echo "'$(basename "$0")'"
echo "pushes files to S3 targets without clobbering what's there already"
echo ;
echo "Choose from 2 types of input";
echo "1)     pipe to its standard input from another process:"
echo "\$(output lines of valid paths to readable files) | $(basename "$0") [ 2> /path/to/error/file ]" ;
echo ;
echo ' - or - ' ;
echo ;
echo '2)     invoke with arguments' ;
echo "$(basename "$0") \$(output valid paths to readable files)  [ 2> /path/to/error/file ] ";
echo ;
echo "******* NOTE:  *******"
echo "Output is verbose!  Do not redirect it unless you first" ;
echo "modify/populate script variable 'profileName'" ;
echo "Or it will 'hang' to wait for your response to prompts you won't see." ;
echo ;
echo "Recommended:  output errors to file for easier QA." ;
echo ;
echo ;
exit
}

function awsCopyPush {
arg=$1;
		echo "processing $arg"
		errString='' ;
				# Checking to ensure a filename was specified and that it exists
		if [ ! -f "$arg" -o ! -r "$arg" ]; then
			echo "ERROR: $arg is not a valid path or file is unreadable" >&2 ;
			continue ;
		fi
		fileName=$(basename "$arg");
		guid=$(echo "$fileName" | cut -f1-4 -d \- ) ;

				# sanity checks for GUID-ness
		if [ "$(echo "$fileName" | tr -dC '-' | wc -c | tr -dC '[0-9]')" != 4 ] ; then
			errString=$(echo "$errString '$arg' file name must have 5 hyphenated parts") ;
		fi
		if [ "$(echo "$fileName" | cut -f1 -d \- )" != 'cpb' -o "$(echo "$fileName" | cut -f2 -d \- )" != 'aacip' -o ! -z "$(echo "$fileName" | cut -f3 -d \- | tr -d '[0-9]')" -o "$(echo "$fileName" | cut -f5 -d \- )" != 'transcript.json' ] ; then
			errString=$(echo "$errString '$arg'"' file name hypenated part(s) must resemble "cpb-aacip-[:digit:]-[:alnum:]-transcript.json"') ;
		fi
		if [ -z "$errString" ]; then
			echo "checking for previous copies" ;
			copyVersion=$(aws s3api list-objects --profile "$profileName" --bucket "$bucketName" --prefix "transcripts/ORIGINAL-$guid/" --query 'Contents[].Key' | grep -c \" | tr -dC '[0-9]') ;
			if [ "$copyVersion" == 0 ] ; then
				copyVersion='';
			else
				copyVersion="_copy$copyVersion" ;
			fi
			echo "copying $arg to S3 $copyVersion" ;
			aws s3api copy-object --profile "$profileName" --bucket "$bucketName" --copy-source "$bucketName/transcripts/$guid/$fileName" --key "transcripts/ORIGINAL-""$guid"/"$guid""-transcript""$copyVersion"".json" --metadata-directive 'COPY' --tagging-directive 'COPY'
			aws s3api put-object --profile "$profileName" --bucket "$bucketName" --key "transcripts/$guid/$fileName" --body "$arg"
		else
			echo "ERROR:  $errString" >&2 ;
			continue ;
		fi
}

# Check to see if a pipe exists on stdin.
if [ -p /dev/stdin ]; then
#        echo "Data was piped to this script!"
        # If we want to read the input line by line
        if [ "$profileNameCount" -lt 2 ]
        then
			export profileName='default' ;
			echo "using default profile" ;
        elif [ -z "$profileName" ] ; then
			echo "Click dialog window to choose an access profile"
			profileName=$(osascript <<EOF
copy paragraphs of "$profileNameList" to profileList
choose from list profileList with prompt "Choose a profile name " with title "S3 Profile Options" default items (item 1 of profileList)
EOF
);
			if [ "$profileName" == 'false' ] ; then
				exit
			fi
			echo "using profile '$profileName'"
		fi
		while IFS= read line; do
#			echo "Line: ${line}"
			awsCopyPush $line ;
		done

elif [ "$#" -ne 0 ]; then
#		echo "No input was found on stdin, skipping!"
	if [ "$profileNameCount" -lt 2 ]
	then
		export profileName='default' ;
		echo "using default profile" ;
	elif [ -z "$profileName" ]; then
		profileName="choose" ;
		while [ "$profileName" == "choose" ]
		do
			echo "type and enter the profile number to use" ;
			echo "$profileNameList" | cat -n
			read profileNum;
			sanity=$(echo "$profileNameList" | head -$profileNum 2>/dev/null | tail -1 2>/dev/null | cut -f2-) ;
			if [ "$sanity" -a ! -z "$(seq 1 $profileNameCount | grep $profileNum)" ]
			then
			export profileName=$sanity ;
			fi ;
		done ;
		echo "using profile '$profileName'" ;
	fi
	for arg in "$@"
	do
		awsCopyPush $arg ;
	done

else
	usage "No input given!" ;
fi

exit ;
