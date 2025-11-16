export CF_Key='d39008d32a8f73c0bb611aab77404e4a9b4ed'
export CF_Email='menglongwoo@aliyun.com'

wget -N https://raw.githubusercontent.com/MenglongWu/cloud-pub/master/bin/acme-ui.sh > /usr/local/bin/acme-ui.sh

chmod +x /usr/local/bin/acme-ui.sh

acme-ui.sh
