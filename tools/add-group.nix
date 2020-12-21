{ users , addGroups }: (mapAttrs (name: value: value.user.extraGroups ++ addGroups ) users)






