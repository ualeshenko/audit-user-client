# audit-user-client

Create files:
- client-audit.service  
- timer-client-audit.timer 
 

Run command:
```
systemctl daemon-reload
systemctl enable timer-client-audit.timer
systemctl start timer-client-audit.timer

systemctl status timer-client-audit.timer

journalctl -u client-audit.service

```
