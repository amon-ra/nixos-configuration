''
-- fortuneteller2k's XMonad config
-- This file is managed by NixOS, don't edit it directly!

import XMonad

import XMonad.Actions.CycleWS

import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.Place
import XMonad.Hooks.SetWMName

import XMonad.Layout.NoBorders
import XMonad.Layout.Spacing
import XMonad.Layout.Tabbed
import XMonad.Layout.ToggleLayouts

import XMonad.Prompt
import XMonad.Prompt.FuzzyMatch
import XMonad.Prompt.Shell

import XMonad.Util.EZConfig
import XMonad.Util.SpawnOnce

import Data.Char
import Data.Monoid
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- 10 workspaces should be enough
ws = ["A","B","C","D","E","F","G","H","I","J"]

fontFamily = "xft:FantasqueSansMono Nerd Font:size=10:antialias=true:hinting=true"

keybindings =
  [ ("M-<Return>",                 spawn "alacritty")
  , ("M-d",                        shellPrompt promptConfig)
  , ("M-q",                        kill)
  , ("M-w",                        spawn "emacsclient -nc")
  , ("M-<F2>",                     spawn "brave")
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
  , ("<Print>",                    spawn "/home/fortuneteller2k/.config/scripts/screenshot.sh wind")
  , ("M-<Print>",                  spawn "/home/fortuneteller2k/.config/scripts/screenshot.sh area")
  , ("M-S-s",                      spawn "/home/fortuneteller2k/.config/scripts/screenshot.sh full")
  , ("M-S-q",                      io (exitWith ExitSuccess))
  , ("M-S-<Delete>",               spawn "slock")
  , ("M-S-c",                      withFocused $ \w -> spawn ("xkill -id " ++ show w))
  , ("M-S-r",                      spawn $ "xmonad --recompile && xmonad --restart")
  , ("M-S-<Left>",                 shiftToPrev >> prevWS)
  , ("M-S-<Right>",                shiftToNext >> nextWS)
  , ("M-<Left>",                   windows W.focusUp)
  , ("M-<Right>",                  windows W.focusDown)
  , ("<XF86AudioMute>",            spawn "/home/fortuneteller2k/.config/scripts/volume.sh mute")
  , ("<XF86AudioRaiseVolume>",     spawn "/home/fortuneteller2k/.config/scripts/volume.sh up")
  , ("<XF86AudioLowerVolume>",     spawn "/home/fortuneteller2k/.config/scripts/volume.sh down")
  , ("<XF86MonBrightnessUp>",      spawn "xbacklight -inc 10")
  , ("<XF86MonBrightnessDown>",    spawn "xbacklight -dec 10")
  ]
  ++
  [ (otherModMasks ++ "M-" ++ key, action tag)
      | (tag, key) <- zip ws (map (\x -> show x) ([1..9] ++ [0]))
      , (otherModMasks, action) <- [ ("", windows . W.greedyView)
                                   , ("S-", windows . W.shift)]
  ]
  where
    toggleFloat w = windows (\s -> if M.member w (W.floating s)
                              then W.sink w s
                              else (W.float w (W.RationalRect 0.15 0.15 0.7 0.7) s))

promptConfig = def
  { font                = fontFamily
  , bgColor             = "#16161c"
  , fgColor             = "#fdf0ed"
  , bgHLight            = "#26bbd9"
  , fgHLight            = "#16161c"
  , borderColor         = "#26bbd9"
  , promptBorderWidth   = 0
  , position            = Top
  , height              = 20
  , historySize         = 256
  , historyFilter       = id
  , showCompletionOnTab = False
  , searchPredicate     = fuzzyMatch
  , sorter              = fuzzySort
  , defaultPrompter     = id $ map toLower
  , alwaysHighlight     = True
  , maxComplRows        = Just 5
  }

layouts = avoidStruts
          $ spacingRaw False (Border 4 4 4 4) True (Border 4 4 4 4) True
          $ toggleLayouts maximized tiled ||| noBorders (tabbed shrinkText tabTheme)
  where
     tiled = smartBorders (Tall nmaster delta ratio)
     nmaster = 1
     ratio = toRational (2/(1+sqrt(5)::Double)) -- inverse golden ratio
     delta = 3/100
     maximized = smartBorders Full

tabTheme = def
  { fontName            = fontFamily
  , activeColor         = "#26bbd9"
  , inactiveColor       = "#16161c"
  , urgentColor         = "#e95678"
  , activeBorderColor   = "#26bbd9"
  , inactiveBorderColor = "#16161c"
  , urgentBorderColor   = "#e95678"
  , activeTextColor     = "#16161c"
  , inactiveTextColor   = "#fdf0ed"
  , urgentTextColor     = "#16161c"
  }

windowRules = placeHook (smart (0.5, 0.5))
  <+> composeAll
  [ className =? "Gimp"                                   --> doFloat
  , (className =? "Ripcord" <&&> title =? "Preferences")  --> doFloat
  , className =? "Xmessage"                               --> doFloat
  , className =? "Peek"                                   --> doFloat
  , className =? "Xephyr"                                 --> doFloat
  , resource  =? "desktop_window"                         --> doIgnore
  , resource  =? "kdesktop"                               --> doIgnore
  , isDialog                                              --> doF W.swapUp <+> doFloat ]
  <+> insertPosition End Newer -- same effect as attachaside patch in dwm
  <+> manageDocks
  <+> manageHook defaultConfig

autostart = do
  spawnOnce "xsetroot -cursor_name left_ptr &"
  spawnOnce "systemctl --user restart polybar &"
  spawnOnce "nitrogen --restore &"
  spawnOnce "xidlehook --not-when-fullscreen --not-when-audio --timer 600 slock \'\' &"
  setWMName "LG3D"

cfg = docks $ ewmh $ def
  { focusFollowsMouse  = True
  , borderWidth        = 1
  , modMask            = mod1Mask
  , workspaces         = ws
  , normalBorderColor  = "#16161c"
  , focusedBorderColor = "#26bbd9"
  , layoutHook         = layouts
  , manageHook         = windowRules
  , logHook            = fadeInactiveLogHook 0.95
  , handleEventHook    = fullscreenEventHook <+> ewmhDesktopsEventHook
  , startupHook        = autostart
  } `additionalKeysP` keybindings

main = xmonad cfg -- "that was easy, xmonad rocks!"
''