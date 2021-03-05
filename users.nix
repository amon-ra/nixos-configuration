let

  passwords = import ./passwords;

  createUser = { username, id, realname, keys }: { groups }: {
    username = username;
    group.gid = id;
    user = {
      description = realname;
      uid = id;
      group = username;
      extraGroups = [ "networkmanager" "users" "video" ] ++ groups;
      home = "/home/${username}";
      isNormalUser = true;
      hashedPassword = builtins.getAttr username passwords;
      openssh.authorizedKeys.keys = keys;
    };
  };

  createUsers = xs: builtins.listToAttrs (
    builtins.map
    (
      x: {
        name = x.username;
        value = (createUser x);
      }
    )
    xs
  );

in createUsers [

  {
    username = "juanra";
    realname = "Juan Ramón Alfaro";
    id = 1000;
    keys = [
    ];
  }

  {
    username = "valentin";
    realname = "Valentin";
    id = 1001;
    keys = [ ];
  }

]
