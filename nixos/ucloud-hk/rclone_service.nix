{
  pkgs,
  lib,
  ...
}: let
  # 定义 rclone 服务的通用配置（模板）
  rcloneService = instance: {
    description = "RClone mount of remote ${instance}";
    requires = ["network-online.target"];
    after = ["network-online.target"];
    path = [pkgs.rclone pkgs.fuse]; # 确保 rclone 和 fusermount 在 PATH 中

    serviceConfig = {
      Type = "notify";
      Environment = [
        "REMOTE_NAME=${instance}"
        "REMOTE_PATH=/"
        "MOUNT_DIR=%h/netdisk/${instance}"
        "RCLONE_CONF=%h/.config/rclone/rclone.conf"
        "RCLONE_TEMP_DIR=/tmp/rclone/%u/${instance}"
        "RCLONE_RC_ON=false"
        "RCLONE_MOUNT_ATTR_TIMEOUT='1s'"
        "RCLONE_MOUNT_DAEMON_TIMEOUT='90s'"
        "RCLONE_MOUNT_DIR_CACHE_TIME='60m'"
        "RCLONE_MOUNT_DIR_PERMS='0777'"
        "RCLONE_MOUNT_FILE_PERMS='0666'"
        "RCLONE_MOUNT_GID='%G'"
        "RCLONE_MOUNT_MAX_READ_AHEAD='128k'"
        "RCLONE_MOUNT_POLL_INTERVAL='1m0s'"
        "RCLONE_MOUNT_UID='%U'"
        "RCLONE_MOUNT_UMASK='022'"
        "RCLONE_MOUNT_VFS_CACHE_MAX_AGE='1h0m0s'"
        "RCLONE_MOUNT_VFS_CACHE_MAX_SIZE='off'"
        "RCLONE_MOUNT_VFS_CACHE_MODE='full'"
        "RCLONE_MOUNT_VFS_CACHE_POLL_INTERVAL='1m0s'"
        "RCLONE_MOUNT_VFS_READ_CHUNK_SIZE='128M'"
        "RCLONE_MOUNT_VFS_READ_CHUNK_SIZE_LIMIT='off'"
        "RCLONE_MOUNT_VOLNAME=\"UNKNOWN_DEFAULT\""
      ];
      EnvironmentFile = "-%h/.config/rclone/${instance}.env"; # 可选：实例特定的环境文件
      ExecStartPre = [
        # 检查 rclone 可执行文件
        "${pkgs.coreutils}/bin/test -x ${pkgs.rclone}/bin/rclone"
        # 检查挂载目录是否存在且可写
        "${pkgs.coreutils}/bin/test -d %h/netdisk/${instance}"
        "${pkgs.coreutils}/bin/test -w %h/netdisk/${instance}"
        # 检查配置文件
        "${pkgs.coreutils}/bin/test -f %h/.config/rclone/rclone.conf"
        "${pkgs.coreutils}/bin/test -r %h/.config/rclone/rclone.conf"
      ];
      ExecStart = lib.concatStringsSep " " [
        "${pkgs.rclone}/bin/rclone mount"
        "--config=%h/.config/rclone/rclone.conf"
        "--allow-other --default-permissions --rc=\${RCLONE_RC_ON}"
        "--cache-tmp-upload-path=\${RCLONE_TEMP_DIR}/upload"
        "--cache-chunk-path=\${RCLONE_TEMP_DIR}/chunks"
        "--cache-works=8 --cache-writes"
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
      ExecStop = "${pkgs.fuse}/bin/fusermount -u %h/netdisk/${instance}";
      Restart = "always";
      RestartSec = "10";
    };

    wantedBy = ["default.target"];
  };

  # 定义实例列表（如 "one" 和 "two"）
  instances = ["onedrive" "googledrive"];

  # 为每个实例生成 systemd 服务
  rcloneInstances = lib.genAttrs instances (instance: rcloneService instance);
in {
  # 将生成的实例服务添加到系统
  systemd.user.services = rcloneInstances;

  # 确保 rclone 和 fuse 已安装
  environment.systemPackages = with pkgs; [rclone fuse];
}
