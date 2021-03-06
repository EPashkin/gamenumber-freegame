{-# LANGUAGE TemplateHaskell, Rank2Types #-}
module GameLogic.Data.Players where

import Control.Monad.State.Lazy
import Data.Array as Arr
import qualified Data.Binary as B
import Control.Lens
import GameLogic.Data.Settings
import GameLogic.Data.World
import GameLogic.Util.RandomState


data Player = Player { _num :: Int    -- sum values of all owned cells
                     , _free :: Int   -- number of values can be placed (used)
                     , _remain :: Int -- counter for _free increase
                     , _aggr :: Int   -- aggro size for AI players
                     , _shieldActive :: Bool  -- shield status
                     , _shieldStrength :: Int -- shield charge level
                                              -- (when >=128 shield activated)
                     , _selectedPos :: WorldPos -- current action position for player
                     }
    deriving (Show)

makeLenses ''Player

type Players = Array Int Player

mkPlayer :: Int -> World -> Int -> Player
mkPlayer aggr' world playerIndex
    = mkPlayer' aggr' $ findPlayerPos playerIndex world

mkPlayer' :: Int -> WorldPos -> Player
mkPlayer' aggr' pos
    = Player { _num = 1
             , _free = 0
             , _remain = 0
             , _aggr = aggr'
             , _shieldActive = False
             , _shieldStrength = 0
             , _selectedPos = pos
             }

mkPlayers :: RandomGen g => Int -> World -> g -> (Players, g)
mkPlayers num' world gen = (players, gen')
    where players = array (1, num')
              $ (activePlayerIndex, (mkPlayer 0 world activePlayerIndex) {_free = 0})
              : [(i, mkPlayer rnd world i) | (i, rnd) <- list]
          lPlayerNums = [2..num']
          (lRandoms, gen') = runState (getNRndAggros (num' - 1)) gen
          list = zip lPlayerNums lRandoms

setPlayer :: Int -> Players -> Player -> Players
setPlayer pos pls cell = pls // [(pos, cell)]

getPlayer :: Int -> Players -> Player
getPlayer ind pls = pls ! ind

toPlayer :: Int -> Lens' Players Player
toPlayer pos = lens (getPlayer pos) (setPlayer pos)

{-# INLINE isAI #-}
isAI :: Player -> Bool
isAI pl = 0 < pl ^. aggr

{-# INLINE isAlive #-}
isAlive :: Player -> Bool
isAlive pl = pl ^. num > 0 || not (isAI pl)

-- apply function to all players
{-# INLINE mapP #-}
mapP :: ((Int, Player) -> a) -> Players -> [a]
mapP func = fmap func . assocs

{-# INLINE mapPIndices #-}
mapPIndices :: (Int -> a) -> Players -> [a]
mapPIndices func = fmap func . Arr.indices

getNRndAggros :: RandomGen g => Int -> State g [Int]
getNRndAggros 0 = return []
getNRndAggros n = do
  value <- randomRSt (aiAggroMin, aiAggroMax)
  list <- getNRndAggros (n-1)
  return (value:list)

instance B.Binary Player where
    put c = do B.put $ c ^. num
               B.put $ c ^. free
               B.put $ c ^. remain
               B.put $ c ^. aggr
               B.put $ c ^. shieldActive
               B.put $ c ^. shieldStrength
               B.put $ c ^. selectedPos
    get = do num' <- B.get
             free' <- B.get
             remain' <- B.get
             aggr' <- B.get
             shieldActive' <- B.get
             shieldStrength' <- B.get
             selectedPos' <- B.get
             return Player { _num = num'
                           , _free = free'
                           , _remain = remain'
                           , _aggr = aggr'
                           , _shieldActive = shieldActive'
                           , _shieldStrength = shieldStrength'
                           , _selectedPos = selectedPos'
                           }
