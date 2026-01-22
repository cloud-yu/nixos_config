{
  config.facter.reportPath =
    if builtins.pathExists ./facter.json
    then ./facter.json
    else throw "Can't find ./facter.json !";
}
