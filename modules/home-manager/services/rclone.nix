{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services."rclone@";
  mkUnit = instance: {
    Unit = {
      Description = "RClone mount of users remote %i using filesystem permissions";
      Documentation = "http://rclone.org/docs/";
      After = ["network-online.target"];
    };
    Service = {
      Environment = [
        ''PATH=/run/wrappers/bin/:''${PATH}''
        ''REMOTE_NAME=%i''
        ''REMOTE_PATH=/''
        ''MOUNT_DIR=%h/netdisk/%i''
        ''POST_MOUNT_SCRIPT=""''
        ''RCLONE_CONF=%h/.config/rclone/rclone.conf''
        ''RCLONE_TEMP_DIR=/tmp/rclone/%u/%i''
        ''RCLONE_RC_ON=false''
        ''RCLONE_MOUNT_ATTR_TIMEOUT="1s"''
        ''RCLONE_MOUNT_DAEMON_TIMEOUT="90s"''
        ''RCLONE_MOUNT_DIR_CACHE_TIME="60m"''
        ''RCLONE_MOUNT_DIR_PERMS=0777''
        ''RCLONE_MOUNT_FILE_PERMS=0666''
        ''RCLONE_MOUNT_GID=%G''
        ''RCLONE_MOUNT_MAX_READ_AHEAD="128k"''
        ''RCLONE_MOUNT_POLL_INTERVAL="1m0s"''
        ''RCLONE_MOUNT_UID=%U''
        ''RCLONE_MOUNT_UMASK=022''
        ''RCLONE_MOUNT_VFS_CACHE_MAX_AGE="1h0m0s"''
        ''RCLONE_MOUNT_VFS_CACHE_MAX_SIZE="off"''
        ''RCLONE_MOUNT_VFS_CACHE_MODE="full"''
        ''RCLONE_MOUNT_VFS_CACHE_POLL_INTERVAL="1m0s"''
        ''RCLONE_MOUNT_VFS_READ_CHUNK_SIZE="128M"''
        ''RCLONE_MOUNT_VFS_READ_CHUNK_SIZE_LIMIT="off"''
        ''RCLONE_MOUNT_VOLNAME="UNKNOWN_DEFAULT"''
      ];
      EnvironmentFile = "-%h/.config/rclone/%i.env"; # 可选：实例特定的环境文件
      ExecStartPre = [
        # 检查 rclone 可执行文件
        "${pkgs.coreutils}/bin/test -x ${pkgs.rclone}/bin/rclone"
        # 检查挂载目录是否存在且可写
        "${pkgs.bash}/bin/bash -c \"if ! \$(${pkgs.coreutils}/bin/test -d \${MOUNT_DIR}); then mkdir -p \${MOUNT_DIR}; fi\" "
        "${pkgs.coreutils}/bin/test -w \${MOUNT_DIR}"
        # 检查配置文件
        "${pkgs.coreutils}/bin/test -f \${RCLONE_CONF}"
        "${pkgs.coreutils}/bin/test -r \${RCLONE_CONF}"
      ];
      ExecStart = lib.concatStringsSep " " [
        "${pkgs.rclone}/bin/rclone mount"
        "--config=\${RCLONE_CONF}"
        "--default-permissions --rc=\${RCLONE_RC_ON}"
        "--cache-tmp-upload-path=\${RCLONE_TEMP_DIR}/upload"
        "--cache-chunk-path=\${RCLONE_TEMP_DIR}/chunks"
        "--cache-workers=8 --cache-writes"
        "--cache-dir=\${RCLONE_TEMP_DIR}/vfs"
        "--cache-db-path=\${RCLONE_TEMP_DIR}/db"
        "--no-modtime --drive-use-trash --stats=0 --bwlimit=40M --cache-info-age=60m"
        "--attr-timeout=\${RCLONE_MOUNT_ATTR_TIMEOUT}"
        "--daemon-timeout=\${RCLONE_MOUNT_DAEMON_TIMEOUT}"
        "--dir-cache-time=\${RCLONE_MOUNT_DIR_CACHE_TIME}"
        "--dir-perms=\${RCLONE_MOUNT_DIR_PERMS}"
        "--file-perms=\${RCLONE_MOUNT_FILE_PERMS}"
        "--gid=\${RCLONE_MOUNT_GID}"
        "--max-read-ahead=\${RCLONE_MOUNT_MAX_READ_AHEAD}"
        "--poll-interval=\${RCLONE_MOUNT_POLL_INTERVAL}"
        "--uid=\${RCLONE_MOUNT_UID}"
        "--umask=\${RCLONE_MOUNT_UMASK}"
        "--vfs-cache-max-age=\${RCLONE_MOUNT_VFS_CACHE_MAX_AGE}"
        "--vfs-cache-max-size=\${RCLONE_MOUNT_VFS_CACHE_MAX_SIZE}"
        "--vfs-cache-mode=\${RCLONE_MOUNT_VFS_CACHE_MODE}"
        "--vfs-cache-poll-interval=\${RCLONE_MOUNT_VFS_CACHE_POLL_INTERVAL}"
        "--vfs-read-chunk-size=\${RCLONE_MOUNT_VFS_READ_CHUNK_SIZE}"
        "--vfs-read-chunk-size-limit=\${RCLONE_MOUNT_VFS_READ_CHUNK_SIZE_LIMIT}"
        "\${REMOTE_NAME}:\${REMOTE_PATH} \${MOUNT_DIR}"
      ];
      ExecStartPost = "/bin/sh -c \${POST_MOUNT_SCRIPT}";
      ExecStop = "/run/wrappers/bin/fusermount3 -u \${MOUNT_DIR}";
      Restart = "always";
      RestartSec = "10";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };

  service = listToAttrs (map
    (instance: {
      name = "rclone@${instance}";
      value = mkUnit instance;
    })
    cfg.instances);
in {
  options = {
    services."rclone@" = {
      enable = mkEnableOption "rclone service for instance";
      instances = mkOption {
        type = types.listOf types.str;
        description = "Instance to enable";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services = service;
  };
}
