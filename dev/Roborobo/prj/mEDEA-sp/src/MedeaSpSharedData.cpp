/*
 *  MedeaSpSharedData.cpp
 *  Roborobo
 *
 *  Created by Nicolas on 3/6/2010.
 *
 */


#include "mEDEA-sp/include/MedeaSpSharedData.h"


//int MedeaSpSharedData::gActiveSun = 1; All sun active, with differents types.
double MedeaSpSharedData::gSunLifetime = 0.3; // sun lifetime in generation (0.5 means changes twice per generation, 2 means change every 2 generations

// ----- ----- ----- ----- -----



bool MedeaSpSharedData::gSwarmOnlineObsUsed = false; // define if the SwarmOnlineObserver is used. If it's the case, the following parameter have to be defined and gEnergyMode should be true
bool MedeaSpSharedData::gDynamicSigma = false;
double MedeaSpSharedData::gSigmaMin = 0.0;
double MedeaSpSharedData::gProbSub = 0.0;
double MedeaSpSharedData::gProbAdd = 0.0;
double MedeaSpSharedData::gDynaStep = 0.0;
double MedeaSpSharedData::gSigmaRef = 0.0; // reference value of sigma
double MedeaSpSharedData::gSigmaMax = 0.0; // maximal value of sigma
double MedeaSpSharedData::gProbRef = 0.0; // probability of transmitting the current genome mutated with sigma ref
double MedeaSpSharedData::gProbMax = 0.0; // probability of transmitting the current genome mutatued withe sigma ref
int MedeaSpSharedData::gEvaluationTime = 0; // how long a controller will be evaluated on a robot

//int MedeaSpSharedData::gMaxEvaluation = 0; // Roughly how many controllers will be evaluated on a robot. Since there is some restart procedure because of the energy, it might happen that more evaluation take place.

double MedeaSpSharedData::gDriftEvaluationRate = 0.0;
double MedeaSpSharedData::gInitLock = 0.0;
double MedeaSpSharedData::gDriftLock = 0.0;
double MedeaSpSharedData::gMaxKeyRange = 0.0;
double MedeaSpSharedData::gDeltaKey = 0.0;
bool MedeaSpSharedData::gSynchronization = true;
// VALUE DEFINED IN CONSTRUCTOR (below)

int MedeaSpSharedData::gExperimentNumber = 0;
int MedeaSpSharedData::gExperiment1_genStart = 10;
int MedeaSpSharedData::gExperiment2_genStart = 20;

int MedeaSpSharedData::g_xStart_EnergyZone = 0;
int MedeaSpSharedData::g_xEnd_EnergyZone = 0;
int MedeaSpSharedData::g_yStart_EnergyZone = 0;
int MedeaSpSharedData::g_yEnd_EnergyZone = 0;

double MedeaSpSharedData::gZoneEnergy_harvestValue = 0; // set in the code, depends on the following params
double MedeaSpSharedData::gZoneEnergy_maxHarvestValue;
double MedeaSpSharedData::gZoneEnergy_minHarvestValue;
int MedeaSpSharedData::gZoneEnergy_maxFullCapacity;
int MedeaSpSharedData::gZoneEnergy_saturateCapacityLevel;

double MedeaSpSharedData::gEnergyMax;
double MedeaSpSharedData::gEnergyRevive;
double MedeaSpSharedData::gEnergyInit;
double MedeaSpSharedData::gN=2;
double MedeaSpSharedData::gB=0.000001;
double MedeaSpSharedData::gDeadTime=1;
bool MedeaSpSharedData::gRandSun;
int MedeaSpSharedData::gNoEnergy;
int MedeaSpSharedData::gNoDenPenTime;
int MedeaSpSharedData::gNbAllowedRobotsBySun;
int MedeaSpSharedData::gTournamentSize;
int MedeaSpSharedData::gSelectionMethod=0; //used to select what type of selection will be used


bool MedeaSpSharedData::gDynamicRespawn;


double MedeaSpSharedData::gMaxPenalizationRate;

int MedeaSpSharedData::gNbTypeResource = 2;
int MedeaSpSharedData::gSparsity;

bool MedeaSpSharedData::gExperimentNoMovements=true; // True if robots cannot use their neural network to move
// ----- ----- ----- ----- ----- 

bool MedeaSpSharedData::gPropertiesLoaded = false; // global variable local to file -- TODO: move specific properties loader in dedicated WorldObserver

// ----- ----- ----- ----- ----- 
