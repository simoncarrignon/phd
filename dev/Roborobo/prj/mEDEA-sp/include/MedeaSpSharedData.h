/*
 *  MedeaSpSharedData.h
 *  roborobo-online
 *
 *  Created by Nicolas on 3/06/10.
 *
 */

#ifndef MEDEASHAREDDATA_H
#define MEDEASHAREDDATA_H

class MedeaSpSharedData {
	
	public: 
	
	static int gActiveSun; // current active sun (index of energy point)
	static double gSunLifetime; // sun lifetime in generation (0.5 means changes twice per generation, 2 means change every 2 generations)
	static bool gRandSun; // if true suns will move in a totally random way. If false sun wil stay in opposite area.

	// -----
	
	static bool gSwarmOnlineObsUsed; // define if the SwarmOnlineObserver is used. If it's the case, the following parameter have to be defined and gEnergyMode should be true
	static bool gDynamicSigma; //if defined to true, modify sigma in a dynamic way. Each robot start with sigma at gSigmaRef and then igma can change between gSigmaMin and gSigmaMax. If defined to true, gSigmaMin, gProbAdd, gProbSub, gDynaStep should be defined
	static double gSigmaMin; // used with gDynamicSigma defined to true
	static double gProbAdd; //probability to increase the value of the current sigma
	static double gProbSub; //probability to decrease the value of the current sigma
	static double gDynaStep; //step used in the drecrease or increas of the value of sigma
	static double gSigmaRef; // reference value of sigma
	static double gSigmaMax; // maximal value of sigma
	static double gProbRef; // probability of transmitting the current genome mutated with sigma ref
	static double gProbMax; // probability of transmitting the current genome mutatued withe sigma ref
	static int gEvaluationTime; // how long a controller will be evaluated on a robot
//	static int gMaxEvaluation; // how long a controller will be evaluated on a robot UNUSED
	static double gDriftEvaluationRate; // when the drift will occure. It's a proportion of the complete experiment. Set to 1 for no drift, to 0 in order to have always usefull information on the two neuron used to localise the nearest energy point. e.g. : use 0.5 in order to have a drift at the middle of the experiment
	static double gInitLock; // the lock value used by the energy points before the drift
	static double gDriftLock; // the lock value used by the nergy points after the drift
	static double gMaxKeyRange; // the range used by the controller to generate keys
	static double gDeltaKey; // the allowed distance between a key and a lock to consider them as matching
	static int gIteration; // used by every class to know what is the current iteration step of roborobo
	static bool gSynchronization; //If set to false, a robot will restart its controller as soon as it has no more energy. If set to true, the robot without energy will wait and reload its controller at the same time as every other robots.

	static int gExperimentNumber; // experiment number. 0: no energy ; 1: energy points ; 2: slow energy zone
	static int gExperiment1_genStart; // exp 1 starts at generations X
	static int gExperiment2_genStart; // exp 2 starts at generation Y

	static int g_xStart_EnergyZone;
	static int g_xEnd_EnergyZone;
	static int g_yStart_EnergyZone;
	static int g_yEnd_EnergyZone;
	
	static double gN;
	static double gB;
	static double gDeadTime;

	static int gNbAllowedRobotsBySun;
	static double gZoneEnergy_harvestValue; // energy harvested in the energy zone in exp 2 -- should be updated dep. on the number of agents in the zone.
	static double gZoneEnergy_maxHarvestValue;
	static double gZoneEnergy_minHarvestValue;
	static int   gZoneEnergy_maxFullCapacity;
	static int   gZoneEnergy_saturateCapacityLevel; // after this numner of agents, everyone only gets minHarvestValue
 
	static double gMaxPenalizationRate; // used only for exp 2 -- should be btw 0 and 1, 1 means penalization is maximal

	static double gEnergyMax; // maximum energy given -- used for initialization, revive and max threshold
	static double gEnergyRevive; // energy given after revive
	static double gEnergyInit; // energy given at start-up
	static int gNoEnergy; // amrocing time 

	static bool gDynamicRespawn; // if true, ignore gEnergyPointRespawnLagMaxValue and use tailored MedeaSp update version.

	static int gNbTypeResource; // Set the number of different sources available in the environment

	static bool gPropertiesLoaded;

	static bool gDenPen; // True if density on fruit is counted 
	static bool gExperimentNoMovements; // True if robots cannot use their neural network to move
	static int gNoDenPenTime; //Time during wich no penality is set
	static int gSparsity;		//Used to build and select the radio network topology
	static int gTournamentSize;
	static int gSelectionMethod ; //used to select what type of selection will be used
	static double gMinimumExpectedValue ; // default: 1
	static double gMaximumExpectedValue; // default: 1
};


#endif
