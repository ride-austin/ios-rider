
if [ -f $SRCROOT/fastlane/.env.default ]
then
	source $SRCROOT/fastlane/.env.default
elif test -z "$CIRCLECI"
then
	echo "Please provide missing ${SRCROOT}/fastlane/.env.default file"
	exit 1
fi

TEMPLATE_FILE=$SRCROOT/scripts/templates/AppConfig.m.template
OUTPUT_FILE=$SRCROOT/FuelMe/AppConfig.m

cp $TEMPLATE_FILE $OUTPUT_FILE

if test -z "$STRIPE_KEY_QA"
then
    echo "Please provide missing \$STRIPE_KEY_QA"
    exit 1
fi

if test -z "$API_KEY"
then
	echo "Please provide missing \$API_KEY"
	exit 1
fi
if test -z "$GOOGLE_MAP_KEY"
then
	echo "Please provide missing \$GOOGLE_MAP_KEY"
	exit 1
fi
if test -z "$GOOGLE_MAP_DIRECTIONS_KEY"
then
	echo "Please provide missing \$GOOGLE_MAP_DIRECTIONS_KEY"
	exit 1
fi
if test -z "$STRIPE_KEY_PRODUCTION"
then
	echo "Please provide missing \$STRIPE_KEY_PRODUCTION"
	exit 1
fi
if test -z "$APPLE_MERCHANT_IDENTIFIER"
then
	echo "Please provide missing \$APPLE_MERCHANT_IDENTIFIER"
	exit 1
fi
if test -z "$BUG_FENDER_KEY"
then
	echo "Please provide missing \$BUG_FENDER_KEY"
fi
if test -z "$PRODUCTION_SERVER_URL"
then
	echo "Please provide missing \$PRODUCTION_SERVER_URL"
	exit 1
fi
if test -z "$QA_SERVER_URL"
then
	echo "Please provide missing \$QA_SERVER_URL"
fi
if test -z "$STAGE_SERVER_URL"
then
	echo "Please provide missing \$STAGE_SERVER_URL"
fi
if test -z "$DEV_SERVER_URL"
then
	echo "Please provide missing \$DEV_SERVER_URL"
fi
if test -z "$FEATURE_SERVER_URL"
then
	echo "Please provide missing \$FEATURE_SERVER_URL"
fi
if test -z "$MD5_PASSWORD_SALT"
then
	echo "Please provide missing \$MD5_PASSWORD_SALT"
	exit 1
fi

sed -i '' -e "s|{{apiKey}}|$API_KEY|g" $OUTPUT_FILE
sed -i '' -e "s|{{GoogleMapKey}}|$GOOGLE_MAP_KEY|g" $OUTPUT_FILE
sed -i '' -e "s|{{googleMapDirectionsKey}}|$GOOGLE_MAP_DIRECTIONS_KEY|g" $OUTPUT_FILE
sed -i '' -e "s|{{stripeKey}}|$STRIPE_KEY_PRODUCTION|g" $OUTPUT_FILE
sed -i '' -e "s|{{stripeKeyQA}}|$STRIPE_KEY_QA|g" $OUTPUT_FILE
sed -i '' -e "s|{{appleMerchantIdentifier}}|$APPLE_MERCHANT_IDENTIFIER|g" $OUTPUT_FILE
sed -i '' -e "s|{{bugFenderKey}}|$BUG_FENDER_KEY|g" $OUTPUT_FILE
sed -i '' -e "s|{{productionServerURL}}|$PRODUCTION_SERVER_URL|g" $OUTPUT_FILE
sed -i '' -e "s|{{qaServerURL}}|$QA_SERVER_URL|g" $OUTPUT_FILE
sed -i '' -e "s|{{stageServerURL}}|$STAGE_SERVER_URL|g" $OUTPUT_FILE
sed -i '' -e "s|{{devServerURL}}|$DEV_SERVER_URL|g" $OUTPUT_FILE
sed -i '' -e "s|{{featureServerURL}}|$FEATURE_SERVER_URL|g" $OUTPUT_FILE
sed -i '' -e "s|{{md5PasswordSalt}}|$MD5_PASSWORD_SALT|g" $OUTPUT_FILE

echo "Done with setup of AppConfig.m"
