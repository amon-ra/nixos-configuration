{ colors }:

''
  -- fortuneteller2k's XMonad config
  -- This file is managed by NixOS, don't edit it directly!

  import XMonad

  import XMonad.Actions.CycleWS
  import XMonad.Actions.Sift
  import XMonad.Actions.TiledWindowDragging
  import XMonad.Actions.WithAll

  import XMonad.Hooks.DynamicLog
  import XMonad.Hooks.EwmhDesktops
  import XMonad.Hooks.InsertPosition
  import XMonad.Hooks.ManageDocks
  import XMonad.Hooks.ManageHelpers
  import XMonad.Hooks.Place
  import XMonad.Hooks.WindowSwallowing

  import XMonad.Layout.DraggingVisualizer
  import XMonad.Layout.Grid
  import XMonad.Layout.LayoutHints
  import XMonad.Layout.NoBorders
  import XMonad.Layout.Renamed
  import XMonad.Layout.Spacing
  import XMonad.Layout.Tabbed
  import XMonad.Layout.ThreeColumns
  import XMonad.Layout.ToggleLayouts

  import XMonad.Prompt
  import XMonad.Prompt.FuzzyMatch
  import XMonad.Prompt.Shell

  import XMonad.Util.EZConfig
  import XMonad.Util.NamedScratchpad
  import XMonad.Util.Run
  import XMonad.Util.SpawnOnce

  import Data.Char
  import Data.Monoid

  import System.IO
  import System.Exit

  import qualified Codec.Binary.UTF8.String as UTF8
  import qualified Data.Map                 as M
  import qualified DBus                     as D
  import qualified DBus.Client              as D
  import qualified XMonad.Util.Hacks        as Hacks
  import qualified XMonad.StackSet          as W

  -- defaults
  modkey = mod1Mask
  term = "alacritty"
  ws = ["A","B","C","D","E","F","G","H","I","J"]
  fontFamily = "xft:FantasqueSansMono Nerd Font:size=10:antialias=true:hinting=true"

  keybindings =
    [ ("M-<Return>",                 safeSpawnProg term)
    , ("M-b",                        namedScratchpadAction scratchpads "terminal")
    , ("M-`",                        distractionLess)
    , ("M-d",                        shellPrompt promptConfig)
    , ("M-q",                        kill)
    , ("M-w",                        safeSpawnProg "emacs")
    , ("M-<F2>",                     safeSpawn "qutebrowser" qutebrowserArgs)
    , ("M-e",                        sendMessage ToggleLayout)
    , ("M-<Tab>",                    sendMessage NextLayout)
    , ("M-n",                        refresh)
    , ("M-s",                        windows W.swapMaster)
    , ("M--",                        sendMessage Shrink)
    , ("M-=",                        sendMessage Expand)
    , ("M-t",                        withFocused toggleFloat)
    , ("M-,",                        sendMessage (IncMasterN 1))
    , ("M-.",                        sendMessage (IncMasterN (-1)))
    , ("C-<Left>",                   prevWS)
    , ("C-<Right>",                  nextWS)
    , ("<Print>",                    safeSpawn "/etc/nixos/scripts/screenshot" ["wind"])
    , ("M-<Print>",                  safeSpawn "/etc/nixos/scripts/screenshot" ["area"])
    , ("M-S-s",                      safeSpawn "/etc/nixos/scripts/screenshot" ["full"])
    , ("M-S-q",                      io (exitWith ExitSuccess))
    , ("M-C-c",                      killAll)
    , ("M-S-<Delete>",               safeSpawnProg "slock")
    , ("M-S-c",                      withFocused $ \w -> safeSpawn "xkill" ["-id", show w])
    , ("M-S-r",                      sequence_ [unsafeSpawn restartcmd, unsafeSpawn restackcmd])
    , ("M-S-<Left>",                 shiftToPrev >> prevWS)
    , ("M-S-<Right>",                shiftToNext >> nextWS)
    , ("M-<Left>",                   windows W.focusUp)
    , ("M-<Right>",                  windows W.focusDown)
    , ("M-S-<Tab>",                  sendMessage FirstLayout)
    , ("<XF86AudioMute>",            safeSpawn "/etc/nixos/scripts/volume" ["toggle"])
    , ("<XF86AudioRaiseVolume>",     safeSpawn "/etc/nixos/scripts/volume" ["up"])
    , ("<XF86AudioLowerVolume>",     safeSpawn "/etc/nixos/scripts/volume" ["down"])
    , ("<XF86AudioPlay>",            safeSpawn "mpc" ["toggle"])
    , ("<XF86AudioPrev>",            safeSpawn "mpc" ["prev"])
    , ("<XF86AudioNext>",            safeSpawn "mpc" ["next"])
    , ("<XF86MonBrightnessUp>",      safeSpawn "brightnessctl" ["s", "+10%"])
    , ("<XF86MonBrightnessDown>",    safeSpawn "brightnessctl" ["s", "10%-"])
    ]
    ++
    [ (otherModMasks ++ "M-" ++ key, action tag)
        | (tag, key) <- zip ws (map show ([1..9] ++ [0]))
        , (otherModMasks, action) <- [ ("", windows . W.greedyView)
                                     , ("S-", windows . W.shift) ] ]
    where 
      distractionLess = sequence_ [unsafeSpawn restackcmd, sendMessage ToggleStruts, toggleScreenSpacingEnabled, toggleWindowSpacingEnabled]
      restartcmd = "xmonad --restart && systemctl --user restart polybar"
      restackcmd = "sleep 1.2; xdo lower $(xwininfo -name polybar-xmonad | rg 'Window id' | cut -d ' ' -f4)"
      qutebrowserArgs = [ "--qt-flag ignore-gpu-blacklist"
                        , "--qt-flag enable-gpu-rasterization"
                        , "--qt-flag enable-native-gpu-memory-buffers"
                        , "--qt-flag num-raster-threads=4"
                        , "--qt-flag enable-oop-rasterization" ]
      toggleFloat w = windows (\s -> if M.member w (W.floating s)
                                      then W.sink w s
                                      else (W.float w (W.RationalRect 0.15 0.15 0.7 0.7) s))

  mousebindings = 
    [ ((modkey .|. shiftMask, button1), dragWindow)
    , ((modkey, button1), (\w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster))
    , ((modkey, button2), (\w -> focus w >> windows W.shiftMaster))
    , ((modkey, button3), (\w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster)) ]

  scratchpads = [ NS "terminal" (term ++ " -t ScratchpadTerm") (title =? "ScratchpadTerm") (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3)) ]

  promptConfig = def
    { font                = fontFamily
    , bgColor             = "#${colors.bg}"
    , fgColor             = "#${colors.fg}"
    , bgHLight            = "#${colors.c1}"
    , fgHLight            = "#${colors.bg}"
    , promptBorderWidth   = 0
    , position            = Top
    , height              = 20
    , historySize         = 256
    , historyFilter       = id
    , showCompletionOnTab = False
    , searchPredicate     = fuzzyMatch
    , sorter              = fuzzySort
    , defaultPrompter     = \_ -> "xmonad λ: "
    , alwaysHighlight     = True
    , maxComplRows        = Just 5
    }

  layouts = avoidStruts $ tiled ||| mtiled ||| tabs ||| centeredMaster ||| grid
    where
       tiled = stripName 3 0 $ gaps 4 4 $ draggingVisualizer $ toggleLayouts maximized (layoutHints (smartBorders tall))
       mtiled = stripName 3 0 $ gaps 4 4 $ draggingVisualizer $ (toggleLayouts maximized (layoutHints (smartBorders (Mirror tall))))
       centeredMaster = stripName 3 0 $ gaps 4 4 $ draggingVisualizer $ toggleLayouts maximized (layoutHints (smartBorders (ThreeColMid 1 (3/100) (1/2))))
       tabs = stripName 2 1 $ gaps 8 0 $ layoutHints (noBorders (tabbed shrinkText tabTheme))
       grid = stripName 3 0 $ gaps 4 4 $ draggingVisualizer $ toggleLayouts maximized (layoutHints (smartBorders Grid))
       maximized = smartBorders (layoutHints Full)
       gaps n k = spacingRaw False (Border n n n n) True (Border k k k k) True
       stripName n k = renamed [Chain [CutWordsLeft n, CutWordsRight k]]
       tall = Tall 1 (3/100) (11/20)

  tabTheme = def
    { fontName            = fontFamily
    , activeColor         = "#${colors.c1}"
    , inactiveColor       = "#${colors.bg}"
    , urgentColor         = "#${colors.c5}"
    , activeTextColor     = "#${colors.bg}"
    , inactiveTextColor   = "#${colors.fg}"
    , urgentTextColor     = "#${colors.bg}"
    , activeBorderWidth   = 0
    , inactiveBorderWidth = 0
    , urgentBorderWidth   = 0
    }

  windowRules =
    placeHook (smart (0.5, 0.5))
    <+> namedScratchpadManageHook scratchpads
    <+> composeAll
    [ className  =? "Gimp"                                 --> doFloat
    , (className =? "Ripcord" <&&> title =? "Preferences") --> doFloat
    , className  =? "Xmessage"                             --> doFloat
    , className  =? "Peek"                                 --> doFloat
    , className  =? "Xephyr"                               --> doFloat
    , className  =? "Sxiv"                                 --> doFloat
    , className  =? "mpv"                                  --> doFloat
    , appName    =? "desktop_window"                       --> doIgnore
    , appName    =? "kdesktop"                             --> doIgnore
    , isDialog                                             --> doF siftUp <+> doFloat ]
    <+> insertPosition End Newer -- same effect as attachaside patch in dwm
    <+> manageDocks
    <+> manageHook defaultConfig

  autostart = do
    spawnOnce "xsetroot -cursor_name left_ptr &"
    spawnOnce "systemctl --user restart polybar &"
    spawnOnce "xwallpaper --zoom .config/nix-config/nixos/config/wallpapers/horizonblurgradient.png &"
    spawnOnce "xidlehook --not-when-fullscreen --not-when-audio --timer 120 slock \'\' &"
    spawnOnce "notify-desktop -u low 'xmonad' 'started successfully'"

  dbusClient = do
      dbus <- D.connectSession
      D.requestName dbus (D.busName_ "org.xmonad.log") opts
      return dbus
    where
      opts = [D.nameAllowReplacement, D.nameReplaceExisting, D.nameDoNotQueue]

  dbusOutput dbus str =
    let
      opath  = D.objectPath_ "/org/xmonad/Log"
      iname  = D.interfaceName_ "org.xmonad.Log"
      mname  = D.memberName_ "Update"
      signal = D.signal opath iname mname
      body   = [D.toVariant $ UTF8.decodeString str]
    in
      D.emit dbus $ signal { D.signalBody = body }

  polybarHook dbus = dynamicLogWithPP $ xmobarPP
    { ppOutput = dbusOutput dbus
    , ppOrder  = \(_:l:_:_) -> [l]
    }

  main' dbus = xmonad . ewmhFullscreen . docks . ewmh . Hacks.javaHack $ def
    { focusFollowsMouse  = True
    , clickJustFocuses   = True
    , borderWidth        = 2
    , modMask            = modkey
    , workspaces         = ws
    , normalBorderColor  = "#${colors.c8}"
    , focusedBorderColor = "#${colors.c1}"
    , layoutHook         = layouts
    , manageHook         = windowRules
    , logHook            = polybarHook dbus
    , handleEventHook    = hintsEventHook <+> swallowEventHook (return True) (return True)
    , startupHook        = autostart
    } 
    `additionalKeysP` keybindings
    `additionalMouseBindings` mousebindings

  main = dbusClient >>= main' -- "that was easy, xmonad rocks!"
''
