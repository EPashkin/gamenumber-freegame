module Application.Game.Logic where

import Control.Lens
import Middleware.FreeGame.Facade
import Middleware.FreeGame.GameState
import Control.Monad.State.Lazy
import View.State


eventHandler :: GameState
eventHandler = do
    updateWindowSize
    overGameState incCounter
    onKeyA
    onKeyB
    
    whenGameState (keyDown KeyP) $ overGameState doChangePaused
    whenGameState (keyDown KeyS) $ overGameState doShieldAction
    whenGameState (keyDown KeyF1) $ overGameState doHelpPlayer
    whenGameState (keyDown KeyF2) $ overIOGameState doSave
    whenGameState (keyDown KeyF3) $ overIOGameState doLoad

updateWindowSize :: GameState
updateWindowSize = do
    Box _ (V2 w h) <- getBoundingBox
    overGameState $ windowSize .~ (w, h)

incCounter100 :: StateData -> StateData
incCounter100 = counter +~ 100

incCounter :: StateData -> StateData
incCounter = counter +~ 1

onKeyA :: GameState
onKeyA = do
    whenM (keyDown KeyA) $ color green $ polygon [V2 20 0, V2 100 20, V2 90 60, V2 30 70]
    get

onKeyB :: GameState
onKeyB = do
    whenGameState (keyDown KeyB) $ overGameState incCounter100
    color green $ polygon [V2 100 0, V2 100 20, V2 90 60, V2 30 70]
    get

{-
eventHandler :: Event -> StateData -> IO State
eventHandler (EventKey key keyState mods pos) state
    | MouseButton LeftButton == key
    , Down                   == keyState
    = return $ startPlacement pos state 
    | MouseButton LeftButton == key
    , Up                     == keyState
    = return $ stopPlacement state 
    | MouseButton RightButton == key
    , Down                    == keyState
    = return $ centering pos state

eventHandler (EventMotion pos) state
    | inPlacementMode state 
    = return $ drawing pos state
    | otherwise
    = return state
-}
