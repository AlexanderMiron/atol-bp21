# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    echo "You can  do: sudo bash ./install.sh"
    exit 1
fi

# set variables
BUILD_CPU=`uname -m`
ARCHITECTURE=""
FILTER_PATH="/usr/lib/cups/filter"
PPD_PATH="/usr/share/cups/model"

# echo information
echo "Start Atol BP-21 driver installation."

# check architecture
case $BUILD_CPU in
	x86_64)
		ARCHITECTURE="64"
	;;
	i[3-6]86)
		ARCHITECTURE="32"
	;;
esac

if test "x$ARCHITECTURE" = "x"
	then
		echo "This driver work on x86 or amd64 architecture"
		exit 1
fi

echo "Your CPU architecture is $ARCHITECTURE bit."


# check installation folder
if test ! -d $FILTER_PATH
	then
		echo "Not found cups filter path in /usr/lib/cups/filter"
		exit 1
fi
if test ! -d $PPD_PATH
	then
		echo "Not found cups model path in /usr/share/cups/model"
		exit 1
fi

echo "Installation folders found."

# make folder for ppd file
mkdir -p $PPD_PATH/atol/
chown -R root:root $PPD_PATH/atol/
chmod -R 755 $PPD_PATH/atol/

# set file permissions
chown -R root:root ./Atol*
chown -R root:root ./raster*
chmod -R 755 ./Atol*
chmod -R 755 ./raster*

# copy files according to architecture
if test $ARCHITECTURE = "32"
	then
		cp ./Atol-BP21_x32.ppd $PPD_PATH/atol/
		cp ./rastertotspl $FILTER_PATH
elif test $ARCHITECTURE = "64" 
	then
		cp ./Atol-BP21_x64.ppd $PPD_PATH/atol/
		cp ./rastertobarcodetspl $FILTER_PATH
fi

echo "    restart spooler - CUPS"
################################################################################
#
# restart 
#
if test -f /etc/init.d/cups
then
  /etc/init.d/cups restart
else
  if test -f /etc/init.d/cupsys
  then
    /etc/init.d/cupsys restart
  fi
fi

echo "Install done. Please check. You will found this driver as Atol"

exit 0
