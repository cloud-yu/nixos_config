{lib, ...}: {
  # WSL2 上用户级核心转储的障碍与处理：
  #
  # 1. 内核层：微软 WSL2 内核无法通过管道调用 dump 处理器（journal 可见
  #    "Core dump to |...systemd-coredump pipe failed"），systemd-coredump 在
  #    WSL 内永远不会成功；且该内核要求 core_pattern 为管道或绝对路径
  #    （相对路径会被拒绝）。../common/kernel.nix 启用的 systemd-coredump 是
  #    为真实内核（ucloud-hk）准备的，此处 mkForce 关闭，改用文件式落盘到
  #    /var/crash，由 tmpfiles 按 10 天期限清理。
  #    fs.suid_dumpable 显式归 0：switch 不会重置未提及的 sysctl，而当前
  #    运行系统里 coredump 模块曾将其设为 2（强制走已损坏的管道）。
  #
  # 2. RLIMIT_CORE 的来源（均经实测验证，无需触碰 /init）：
  #    - 系统服务：继承 PID1 的 unlimited，无需配置；
  #    - 用户服务：user manager 经 PAM systemd-user 应用 common/kernel.nix
  #      的 loginLimits，已实测为 4096000000/4096000000（= core 4000000 KB）；
  #    - 终端 shell：不经过 PAM、不在 systemd 之下，由
  #      home-manager/nixos-wsl 的 ~/.config/fish/conf.d/10-core-limit.fish
  #      抬升；zsh 登录场景由下方 shellInit 兜底。
  #
  # 3. zsh 的 ulimit 单位是 512 字节块：8000000 → 4096000000 字节，与上述一致。
  #    bash 登录未覆盖（当前登录 shell 为 fish）。

  systemd.coredump.enable = lib.mkForce false;
  boot.kernel.sysctl."fs.suid_dumpable" = 0;
  boot.kernel.sysctl."kernel.core_pattern" = "/var/crash/core.%e.%p";

  systemd.tmpfiles.rules = [
    "d /var/crash 1777 root root 10d"
  ];

  programs.zsh.shellInit = ''
    ulimit -c 8000000
  '';
}
