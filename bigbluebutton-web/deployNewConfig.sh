echo "Copy configfile to ${BBB_SERVER}"
scp ./grails-app/conf/bigbluebutton.properties root@${BBB_SERVER}:/usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties.new

echo "Stop existing bbb-conf serviceand start service again"

ssh root@${BBB_SERVER} << 'EOF'
    echo extracting BBB Secret and URL
    BBB_DATA=$(bbb-conf --secret);
    REGEX_SECRET='[[:space:]]Secret:[[:space:]]([A-Za-z0-9]+?)[[:space:]]'
    REGEX_SERVER='URL:[[:space:]](.+?)\/bigbluebutton\/[[:space:]]'
    REGEX_DOMAIN='URL:[[:space:]]https:\/\/(.+?)\/bigbluebutton\/[[:space:]]'
    BBB_SECRET=$([[ "$BBB_DATA" =~ $REGEX_SECRET ]] && echo ${BASH_REMATCH[1]})
    BBB_URL=$([[ "$BBB_DATA" =~ $REGEX_SERVER ]] && echo ${BASH_REMATCH[1]})
    BBB_DOMAIN=$([[ "$BBB_DATA" =~ $REGEX_DOMAIN ]] && echo ${BASH_REMATCH[1]})
    BBB_SECRET_PLACEHOLDER='BBBSECRETPLACEHOLDER'
    BBB_URL_PLACEHOLDER='BBBURLPLACEHOLDER'
    BBB_DOMAIN_PLACEHOLDER='BBBDOMAINPLACEHOLDER'
    echo replacing Placeholders with Secret and URL
    echo "$BBB_SECRET_PLACEHOLDER to $BBB_SECRET"
    echo "$BBB_URL_PLACEHOLDER to $BBB_URL"
    echo "$BBB_DOMAIN_PLACEHOLDER to $BBB_DOMAIN"
    cd /usr/share/bbb-web/WEB-INF/classes
    sed -in -e "s|${BBB_SECRET_PLACEHOLDER}|${BBB_SECRET}|g" -e "s|${BBB_URL_PLACEHOLDER}|${BBB_URL}|g" -e "s|${BBB_DOMAIN_PLACEHOLDER}|${BBB_DOMAIN}|g" bigbluebutton.properties.new
    rm bigbluebutton.properties.newn
    mv bigbluebutton.properties bigbluebutton.properties.backup
    mv bigbluebutton.properties.new bigbluebutton.properties
    bbb-conf --restart
EOF