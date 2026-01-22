{pkgs, ...}: {
  xdg.configFile."systemd/user/rclone@.service".text = ''
    [Unit]
    Description=RClone mount of user's remote %i using filesystem permissions
    Documentation=http://rclone.org/docs/
    After=network-online.target

    [Service]
    Type=simple
    # Set up environment
    Environment=REMOTE_NAME="%i"
    Environment=REMOTE_PATH="/"
    Environment=MOUNT_DIR="%h/netdisk/%i"
    Environment=POST_MOUNT_SCRIPT=""
    Environment=RCLONE_CONF="%h/.config/rclone/rclone.conf"
    Environment=RCLONE_TEMP_DIR="/tmp/rclone/%u/%i"
    Environment=RCLONE_RC_ON=false

    # Default arguments for rclone mount. Can be overridden in the environment file
    Environment=RCLONE_MOUNT_ATTR_TIMEOUT="1s"
    Environment=RCLONE_MOUNT_DAEMON_TIMEOUT="90s"
    Environment=RCLONE_MOUNT_DIR_CACHE_TIME="60m"
    Environment=RCLONE_MOUNT_DIR_PERMS="0777"
    Environment=RCLONE_MOUNT_FILE_PERMS="0666"
    Environment=RCLONE_MOUNT_GID="%G"
    Environment=RCLONE_MOUNT_MAX_READ_AHEAD="128k"
    Environment=RCLONE_MOUNT_POLL_INTERVAL="1m0s"
    Environment=RCLONE_MOUNT_UID="%U"
    Environment=RCLONE_MOUNT_UMASK="022"
    Environment=RCLONE_MOUNT_VFS_CACHE_MAX_AGE="1h0m0s"
    Environment=RCLONE_MOUNT_VFS_CACHE_MAX_SIZE="off"
    Environment=RCLONE_MOUNT_VFS_CACHE_MODE="full"
    Environment=RCLONE_MOUNT_VFS_CACHE_POLL_INTERVAL="1m0s"
    Environment=RCLONE_MOUNT_VFS_READ_CHUNK_SIZE="128M"
    Environment=RCLONE_MOUNT_VFS_READ_CHUNK_SIZE_LIMIT="off"

    # Add fusemount3 path to environment
    Environment=PATH=/run/wrappers/bin:''${PATH}
    # Overwrite default environment settings with settings from the file if present
    EnvironmentFile=-%h/.config/rclone/%i.env

    # Check the rclone is installed
    ExecStartPre=${pkgs.coreutils}/bin/test -x ${pkgs.rclone}/bin/rclone

    # Check the mount directory exists and writable
    ExecStartPre=${pkgs.coreutils}/bin/test -d ''${MOUNT_DIR}
    ExecStartPre=${pkgs.coreutils}/bin/test -w ''${MOUNT_DIR}

    # Check the rclone configuration file exists and readable
    ExecStartPre=${pkgs.coreutils}/bin/test -f ''${RCLONE_CONF}
    ExecStartPre=${pkgs.coreutils}/bin/test -r ''${RCLONE_CONF}

    # Mount rclone fs
    ExecStart=${pkgs.rclone}/bin/rclone mount \
          --config="''${RCLONE_CONF}" \
          --allow-other --default-permissions --rc="''${RCLONE_RC_ON}" \
          --cache-tmp-upload-path="''${RCLONE_TEMP_DIR}/upload" \
          --cache-chunk-path="''${RCLONE_TEMP_DIR}/chunks" \
          --cache-workers=8 --cache-writes \
          --cache-dir="''${RCLONE_TEMP_DIR}/vfs" \
          --cache-db-path="''${RCLONE_TEMP_DIR}/db" \
          --no-modtime --drive-use-trash --stats=0 --bwlimit=40M --cache-info-age=60m \
          --attr-timeout="''${RCLONE_MOUNT_ATTR_TIMEOUT}" \
          --daemon-timeout="''\${RCLONE_MOUNT_DAEMON_TIMEOUT}" \
          --dir-cache-time="''${RCLONE_MOUNT_DIR_CACHE_TIME}" \
          --dir-perms="''${RCLONE_MOUNT_DIR_PERMS}" \
          --file-perms="''${RCLONE_MOUNT_FILE_PERMS}" \
          --gid="''${RCLONE_MOUNT_GID}" \
          --max-read-ahead="''${RCLONE_MOUNT_MAX_READ_AHEAD}" \
          --poll-interval="''${RCLONE_MOUNT_POLL_INTERVAL}" \
          --uid="''${RCLONE_MOUNT_UID}" \
          --umask="''${RCLONE_MOUNT_UMASK}" \
          --vfs-cache-max-age="''${RCLONE_MOUNT_VFS_CACHE_MAX_AGE}" \
          --vfs-cache-max-size="''${RCLONE_MOUNT_VFS_CACHE_MAX_SIZE}" \
          --vfs-cache-mode="''${RCLONE_MOUNT_VFS_CACHE_MODE}" \
          --vfs-cache-poll-interval="''${RCLONE_MOUNT_VFS_CACHE_POLL_INTERVAL}" \
          --vfs-read-chunk-size="''${RCLONE_MOUNT_VFS_READ_CHUNK_SIZE}" \
          --vfs-read-chunk-size-limit="''${RCLONE_MOUNT_VFS_READ_CHUNK_SIZE_LIMIT}" \
          ''${REMOTE_NAME}:''${REMOTE_PATH} ''${MOUNT_DIR}

    # Execute post mount script if set
    ExecStartPost=/bin/sh -c "''${POST_MOUNT_SCRIPT}"

    # Unmount rclone fs
    ExecStop=fusermount3 -u ''${MOUNT_DIR}

    Restart=always
    RestartSec=10

    [Install]
    WantedBy=default.target
  '';
}
