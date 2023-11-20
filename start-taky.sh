#!/bin/bash
echo "Initial /data:"
find /data -print

if [ "$RESET" ]
then
    echo "Resetting /data config"
    rm -rf /data/taky
fi

# Need to start as root to be able to change ownership of /data
chown tak:tak /data

# Deal with no config info
if [ ! -f /data/taky/taky.conf ]
then
    echo "USESSL variable is: $USESSL"
    if [ ! "$USESSL" ]
    then
        echo "Setting up as TCP since \$USESSL not set"
        NOSSL=" --no-ssl "
    fi

    # Assign hostname if provided
    if [ "$HOSTNAME" ]
    then
        echo "Setting host name to: $HOSTNAME"
        HOSTNAME=" --host $HOSTNAME "
    fi
    
    # Use our external IP as public IP if not provided
    if [ ! "$PUBLICIP" -a ! -f /data/taky/taky.conf ]
    then
        # No taky config, so try to find out an external IP
        echo "No Public IP provided, using our external IP:"
        PUBLICIP=`curl --silent ifconfig.me`
        echo $PUBLICIP
    fi

    # Assign the public IP for takyctl
    if [ "$PUBLICIP" ]
    then
        echo "Setting public IP to: $PUBLICIP"
        PUBLICIP=" --public-ip $PUBLICIP "
    fi

    # Create config files as takuser
    su -c "/usr/local/bin/takyctl setup $NOSSL $HOSTNAME $PUBLICIP --user tak /data/taky"
fi

#now start taky as tak user
su -c "/usr/local/bin/taky -c /data/taky/taky.conf -l info" tak
