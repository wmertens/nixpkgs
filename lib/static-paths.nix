{
  # These should be strings, not paths

  tz-info = "/etc/localtime";
  tz-dir = "/etc/zoneinfo";

  ca-bundle = "/etc/ssl/certs/ca-certificates.crt";
  
  nixos-config-dir = "/etc/nixos";
  nixos-config = "${nixos-config-dir}/configuration.nix";
  
  nix-config-dir = "/etc/nix";
  nix-config = "${nix-config-dir}/config.nix";

  root-crontab = "/etc/crontab";

  # Legacy paths
  passwd = "/etc/passwd";
  group = "/etc/group";
  shadow = "/etc/shadow";
  resolv = "/etc/resolv.conf";
  nsswitch = "/etc/nsswitch.conf";
}
/*
   260    4 -rw-r--r--   1 root     wheel         664 May 14 16:02 /etc/nixos/configuration.nix
   276    4 -rw-r--r--   1 root     root           50 May 15 14:43 /etc/resolv.conf
 70896    4 -rw-------   1 root     root          668 Apr 29 10:59 /etc/ssh/ssh_host_dsa_key
 70763 6396 -r--r--r--   1 root     root      6548366 Apr 29 10:57 /etc/udev/hwdb.bin
 70875    4 -r--r--r--   1 root     root           33 Apr 29 10:59 /etc/machine-id
101152    4 -r--r-----   1 root     root          518 May  7 07:56 /etc/sudoers
101220    4 -rw-r--r--   1 root     root          501 May  7 07:56 /etc/group
101221    4 -rw-r--r--   1 root     root         3161 May  7 07:56 /etc/passwd
101222    4 -rw-------   1 root     root         1421 May  7 07:56 /etc/shadow
101231    4 -rw-------   1 root     root          222 May  7 07:56 /etc/crontab
 70886    0 -rw-r--r--   1 root     root            0 Apr 29 10:59 /var/cron/cron.deny
*/
