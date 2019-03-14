#!/bin/bash
#Take a video file and split, combine, scale, rotate, crop, change video quality, and more
echo "=================================== 
Options: 
  (a) Convert video to different format (.mp4, .avi, .mov...)      
  (b) Split video into parts   
  (c) Combine two parts into one   
  (d) Rotate the video   
  (e) Crop the video     
  (f) Change volume      
  (g) Get audio (output will be a .aac file)    
  (h) Get info on video or audio file           
  (i) Play video or audio                       
==================================="

read -p 'Please choose an option: ' Option

case "${Option}" in         
        a|A)
        #convert video to different format
        echo "You choose to convert video to a new format"
        read -p 'Please enter the file name: ' oldFile
	if [[ -f "${oldFile}" ]]
        then
		 echo 'File exists. . .'
                 backup_file "${oldFile}"
		 read -p "Enter what you would like to call the new file (without the extension): " newFile
                 read -p "Enter the format you would like to change to (ex .mov): " format
                 if [[ "${format}" -ge 5 || "${format}" -le 0 ]]
		 then 
		     echo 'Invalid input for format'
		 else
		     echo "Now converting to ${format}"
		     ffmpeg -i "${oldFile}" "${newFile}${format}"
                     echo "done..."
		 fi
        else
	    echo 'File does not exist!'
            exit 1
        fi
        ;;
        b|B)
        #Split the video into parts
        echo 'You choose to split the video into two parts! '
        echo 
        read -p 'Please enter the name of the file you will be splitting: ' oldFile
        read -p 'Please enter the base name of the files you will be creating (without the extension): ' newFile
        extension="${oldFile: -4}"
        
        if [[ -f "${oldFile}"  ]]
        then
          echo 'File exists. . .'
          
           echo 'the length of each value must be 2 and cannot exceed two  ex. 04'
	   echo 'Note: the next part will start where the first part ends and go to the end. ex if the first part is only 30s long                                                                                   the second part will start at 30s and go to the end ov the file'
	   read -p 'Please enter the hours value: ' hrs
	   read -p 'Please enter the minutes value: ' min
	   read -p 'Please enter the seconds value: ' sec
	   length=""${hrs}":"${min}":"${sec}""
        
          ffmpeg -i "${oldFile}" -t "${length}" -c copy  "${newFile}"1"${extension}" -ss "${length}" -codec copy "${newFile}"2"${extension}"
          echo 'done. . .'
       else
          echo 'File does not exist!'
          exit 1
       fi
       
        ;;
        c|C)
        #compine mulitple parts
        echo 'You choose to combine two parts together!'
        read -p 'Please enter the name of the first file: ' firstFile
	read -p 'Please enter the name of the second file: ' secondFile
        read -p 'Please enter the name of the file being created (with the extension of files being combined): ' newFile
       
         if [[ -f "${firstFile}" && -f "${secondFile}" ]]
         then
           echo 'File exists. . .'
           ffmpeg -i "concat:"${firstFile}"|"${secondFile}"" -c copy "${newFile}"
           echo 'done. . .'
         else
           echo 'File does not exist!'
           exit 1
         fi


        ;;
        d|D)
        #rotate the video
	echo 'you choose rotate the video!'
        echo '(1) rotate 90 degrees Counter Clockwise and flip the video vertically
(2) rotate 90 degrees Counter Clockwise
(3) rotate 90 Clockwise and flip the video vertically
(4) rotate 90 Clockwise'
        echo
        read -p 'Please choose an option: ' pick
        read -p 'Please enter the name of the file you want to rotate: ' oldFile
	read -p 'Please enter the name of the file you are creating (without the extension): ' newFile
        extension="${oldFile: -4}" 
       
        if [[ -f "${oldFile}"  ]]
        then
          echo 'File exists. . .'

	  case "${pick}" in
	  1)
	      ffmpeg -i "${oldFile}" -vf "transpose=0" "${newFile}${extension}"
          ;;
          2)
	      ffmpeg -i "${oldFile}" -vf "transpose=2" "${newFile}${extension}"
          ;;
          3)         
              ffmpeg -i "${oldFile}" -vf "transpose=3" "${newFile}${extension}"
          ;;
          4)
	      ffmpeg -i "${oldFile}" -vf "transpose=1" "${newFile}${extension}"
          ;;
          *)
              echo 'Supply a valid option. ' >&2
              exit 1
          ;;
          esac
     
          echo 'done. . .'
       else
          echo 'File does not exist!'
          exit 1
       fi
    ;;
    e|E)
    #crpo the video
       echo 'you chooose to crop the video!
       cropping a video might affect the video quality'

       read -p 'Please enter the name of the video file you want too crop: ' oldFile
       read -p 'Please enter the width: ' width
       read -p 'Please enter the height: ' height
       echo

       echo 'Note: x which indicates the x coordinate of the rectangle that we want to crop from the original video.
       The left of the video would be zero. You can omit this variable if you want and ffmpeg will take x as 
       zero so it will crop from the left part of the video.'
       echo
       
       read -p 'Please enter a value for x: ' x
       echo

       echo 'Note: y indicates the y coordinate of the rectangle that we want to crop from the original video'
       echo

       read -p 'Please enter the value for y: ' y
       read -p 'Please enter the name of the file being created (without the extension): ' newFile

       if [[ -f "${oldFile}"  ]]
       then
          echo 'File exists. . .'
	  extension="${oldFile: -4}"
          ffmpeg -i "${oldFile}" -filter:v "crop=${width}:${height}:${x}:${y}" "${newFile}${extension}"
          echo 'done. . .'
       else
          echo 'File does not exist!'
          exit 1
       fi

     
       
    ;;
    f|F)
    #Change volume
	echo 'You choose to change the volume!'
        read -p 'Please enter the name of the file: ' oldFile 
        read -p 'Please enter the new value of the volume you would like the file too be: ' volumeMultiplier
        read -p 'Please enter the name of the new file (without the extension): ' newFile

	if [[ -f "${oldFile}"  ]]
        then
	  echo 'File exists. . .'
          extension="${oldFile: -4}"
	  ffmpeg -i "${oldFile}" -filter:a "volume=${volumeMultiplier}" "${newFile}${extension}"
          echo 'done. . .'
        else 
	  echo 'File does not exist!'
	  exit 1
        fi
    ;;
    g|G)
    #get audio from a video file
	echo 'You choose to get the audio from a file! (output will be a .aac file)'
	read -p 'Please enter the name of the file: ' oldFile
        read -p 'Please enter the name of the .aac file you will be creating (without the extension): ' newFile
        if [[ -f "${oldFile}"  ]]
        then
          echo 'File exists. . .'
          ffmpeg -i "${oldFile}" -vn -acodec copy "${newFile}".aac
          echo 'done. . .'
        else
          echo 'File does not exist!'
          exit 1
        fi
    ;;
    h|H)
    #get video/audioo info
    echo 'You choose to get a video/audio files information'
    read -p 'Please enter the File you want information on: ' getInfo
    read -p 'please enter a name for a file to store the information (without the extension): ' newFile   
      if [[ -f "${getInfo}"  ]]
      then
          echo 'File exists. . .'
          ffmpeg -i "${getInfo}" -hide_banner
          echo 'done. . .'
      else
          echo 'File does not exist!'
          exit 1
      fi
    ;;
    i|I)
    #Play a video or audio file
    echo 'You choose to play a video or audio file!'
    echo 'Main options:
          -fs   (start in fullscreen mode)
          -an   (disable audio)
          -sn   (disable subtitles)
          -nodisp   (disable the graphical display)
          -noborder (borderless window)
          ========================================='
    read -p 'Please select an option or press enter for no potion: ' option
    read -p 'Please enter the name of the file you want to play: ' play
    if [[ -f "${play}"  ]]
        then
          echo 'File exists. . .'
          echo 'While Playing enter:
                q, ESC    (to quit)
                p, SPC    (to pause, p again to resume playing)
                f         (tggle full screen)
                m         (toggle mute)
                0 - 9     (increase or decrease the volume 0 being lowest)
                =========================================================='            
          echo 'Now Playing. . .'
          if [[ "${ption}" == '' ]]
          then
	      ffplay "${play}"
          else
              ffplay "${option}" "${play}"
          fi   
        else
          echo 'File does not exist!'
          exit 1
        fi     
	
    ;;
    *)
      echo 'Supply a valid option. ' >&2
      exit 1
    ;;
esac


