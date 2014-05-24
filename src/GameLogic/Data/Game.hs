{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE Rank2Types #-}
module GameLogic.Data.Game where

import System.Random
import Control.Lens
import GameLogic.Data.Cell
import GameLogic.Data.World
import GameLogic.Data.Player


data Game = Game { _world :: World
                 , _players :: Players
                 , _centerPos :: WorldPos -- position in center of screen
                 , _selectedPos :: WorldPos -- current action position for active player
                 , _placementMode :: Bool
                 , _rndGen :: StdGen }
  deriving (Show)
  
makeLenses ''Game

--TODO: to config
defWorldSize = 8::Int
defNumPlayers = 16::Int
defSeed = 0::Int -- set not 0 for debug purposes
activePlayerIndex = 1::Int

mkGameDef :: World -> StdGen -> Game 
mkGameDef world gen 
    = Game { 
    _world = world
    , _players = mkPlayers defNumPlayers
    , _rndGen = gen
    , _centerPos = pos
    , _selectedPos = pos
    , _placementMode = False
    } where pos = findPlayerPos activePlayerIndex world

cellOfGame :: WorldPos -> Traversal' Game Cell 
cellOfGame pos = world . cellOfWorld pos
