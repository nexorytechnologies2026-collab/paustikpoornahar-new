#!/bin/bash
(crontab -l | grep -v "/usr/bin/php D:/xampp-new/htdocs/paustik-poornahar-admin/artisan dm:disbursement") | crontab -
(crontab -l ; echo "00 11 * * 5 /usr/bin/php D:/xampp-new/htdocs/paustik-poornahar-admin/artisan dm:disbursement") | crontab -
(crontab -l | grep -v "/usr/bin/php D:/xampp-new/htdocs/paustik-poornahar-admin/artisan restaurant:disbursement") | crontab -
(crontab -l ; echo "00 11 * * 3 /usr/bin/php D:/xampp-new/htdocs/paustik-poornahar-admin/artisan restaurant:disbursement") | crontab -
