#!/bin/bash

NAMESPACE=$1
VOLUME=$2

TMPFILE=$(mktemp /tmp/tmp.XXXXXXXXXXXXX)
CHKFILE=$(mktemp /tmp/chk.XXXXXXXXXXXXX)

if [ -z "$NAMESPACE" -o "$NAMESPACE" = " " ]; then
    echo "A Namepace must be provided or select ALL"
    exit 2
fi
case "$NAMESPACE" in
        "ALL")
            oc get pv --no-headers 2> $CHKFILE
            RESULT=$?
            NOVOL=$(grep "No resources" $CHKFILE | wc -l)
            if [ ! $RESULT -eq 0 ] || [ $NOVOL -gt 0 ]; then
                echo "Error while getting EBS volumes information"
                exit 0
            else
                oc get pv -o=custom-columns=NAME:.spec.awsElasticBlockStore.volumeID --no-headers | cut -d "/" -f 4 > $TMPFILE
                while read vol
                do
                    echo "Creating snapshot for EBS volume " $vol
                    aws ec2 create-snapshot --volume-id $vol --description "Automted Snapshot by aws-ocp-snap"
                done < $TMPFILE
            fi
            ;;
        *)
            if [ -z "$VOLUME" -o "$VOLUME" = " " ]; then
                echo "A Volume must be provided or select ALL"
                exit 2
            fi
            case "$VOLUME" in
                    "ALL")
                        oc get pvc --no-headers -n $NAMESPACE 2> $CHKFILE
                        RESULT=$?
                        NOVOL=$(grep "No resources" $CHKFILE | wc -l)
                        if [ ! $RESULT -eq 0 ] || [ $NOVOL -gt 0 ]; then
                            echo "Error while getting EBS volumes information"
                            exit 2
                        else
                            oc get pv $(oc get pvc -n $NAMESPACE -o=custom-columns=NAME:.spec.volumeName --no-headers) -o=custom-columns=NAME:.spec.awsElasticBlockStore.volumeID --no-headers | cut -d "/" -f 4 > $TMPFILE
                            while read vol
                            do
                                echo "Creating snapshot for EBS volume " $vol
                                aws ec2 create-snapshot --volume-id $vol --description "Automted Snapshot by aws-ocp-snap"
                            done < $TMPFILE
                        fi
                        ;;
                    *)
                        oc get pvc --no-headers $VOLUME -n $NAMESPACE &>/dev/null
                        if [ ! $? -eq 0 ]; then
                            echo "Error while getting EBS volumes information"
                            exit 2
                        else
                            oc get pv $(oc get pvc $VOLUME -n $NAMESPACE -o=custom-columns=NAME:.spec.volumeName --no-headers) -o=custom-columns=NAME:.spec.awsElasticBlockStore.volumeID --no-headers | cut -d "/" -f 4
                            NOVOL=$(grep "No resources found" $TMPFILE | wc -l)
                            if [ $NOVOL -gt 0 ];then
                                echo "There are no presistent volumes configured"
                                exit 1
                            else
                                while read vol
                                do
                                    echo "Creating snapshot for EBS volume " $vol
                                    aws ec2 create-snapshot --volume-id $vol --description "Automted Snapshot by aws-ocp-snap"
                                done < $TMPFILE
                            fi
                        fi
                        ;;
            esac
            ;;
esac
