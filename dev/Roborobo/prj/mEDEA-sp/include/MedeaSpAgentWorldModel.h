/*
 *  MedeaSpAgentWorldModel.h
 *  roborobo-online
 *
 *  Created by Nicolas on 15/04/10.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */


#ifndef MedeaSpEVOLVINGROBOTAGENTWORLDMODEL_H
#define MedeaSpEVOLVINGROBOTAGENTWORLDMODEL_H 

#include "RoboroboMain/common.h"
#include "RoboroboMain/roborobo.h"

#include "WorldModels/EvolvingRobotAgentWorldModel.h"

//class World;

class MedeaSpAgentWorldModel : public EvolvingRobotAgentWorldModel
{
	protected:
		
		std::vector<double> _energyPointDirectionAngleValue; // angle to closest energy point -- normalized btw -1 and +1
		std::vector<double> _energyPointDistanceValue ; // distance to the closest energy point -- normalized btw 0  and 1
		
		bool _isActive; // agent stand still if not.

		double _energyLevel;
		double _energyFound;
		double _deltaEnergy;

		double _fitness;
		std::vector<double> _vectorFitnesses;

		std::vector<double> _angleToClosestEnergyPoint;
		std::vector<double> _distanceToClosestEnergyPoint;

		int _fatherId;
		std::vector<double> _energyCounter;


		int _dateOfBirth;

		//syncronization timer 
		int _lifeTime; //number of iteration since the selection of the current geneome
		bool _waitForGenome; //true if the robot is on waiting mode 
		int _maturity; //timer  used to see if the robot is mature, ie. if he can transmit its genome.
		 

		 
	public:
		//Initializes the variables
		MedeaSpAgentWorldModel();
		~MedeaSpAgentWorldModel();

		double getEnergyPointDirectionAngleValue(int type);
		void setEnergyPointDistanceValue( int type,double __value );

		double getEnergyPointDistanceValue(int type);
		void setEnergyPointDirectionAngleValue(int type, double __value);

		double getEnergyLevel();
		void setEnergyLevel(double inValue);

		double getEnergyFound();
		void setEnergyFound(double inValue);
		
		double getDeltaEnergy();
		void setDeltaEnergy(double inValue);

		bool getActiveStatus();
		void setActiveStatus( bool __isActive );

		void setAngleToClosestEnergyPoint(int type, double __value );
		double getAngleToClosestEnergyPoint(int type);
		
		void setDistanceToClosestEnergyPoint(int type, double __value );
		double getDistanceToClosestEnergyPoint(int type);
		
		double getAbilityToForage();
		
		void setFatherId(int fatherId);
		int getFatherId();
		
		void setMaturity(int maturity);
		int getMaturity();
		
		void setFitness(double fitness);
		double getFitness();

		void setDateOfBirth(int DOB);
		int getDateOfBirth();



		void vectorFitnessesPull();
		void vectorFitnessesPush(double energy);
		double vectorFitnessesGet(int i); 
		int vectorFitnessesSize(); 
		//
		// evolutionary engine

		std::map<int, double > _fitnessList;
		std::map<int, std::vector<double> > _genomesList;
		std::map<int, float > _sigmaList;
		std::vector<double> _currentGenome;
		float _currentSigma;
		
		void resetActiveGenome();
		int getLifeTime();
		void setLifeTime(int lifeTime);
		void setWaitForGenome(bool wait);
		bool getWaitForGenome();
		// ANN
		double _minValue;
		double _maxValue;
		int _nbLayer;
		int _nbHiddenNeurons;
		
		void setEnergyCounter(std::vector<double> __energyCounter);
		void setEnergyCounterOfOneRessource(int ressource,double value);
		double getEnergyCounterOfOneRessource(int ressource);
		std::vector<double> getEnergyCounter();//return a vector where a stored amount of energy take from all source type of the environnement
		void resetEnergyCounter();//Set all energy counter to zero
		void setWaitingTime(int arg1);
		void computeFitness();
};


#endif

