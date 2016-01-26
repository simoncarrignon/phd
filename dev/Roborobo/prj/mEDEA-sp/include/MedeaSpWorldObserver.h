/*
 *  WorldObserver.h
 *  roborobo-online
 *
 *  Created by Nicolas on 25/05/10
 *
 */



#ifndef MEDEAWORLDOBSERVER_H
#define MEDEAWORLDOBSERVER_H

#include "RoboroboMain/common.h"
#include "RoboroboMain/roborobo.h"

#include "Observers/Observer.h"

#include "mEDEA-sp/include/MedeaSpSharedData.h"
#include "mEDEA-sp/include/MedeaSpAgentWorldModel.h"
#include "mEDEA-sp/include/MedeaSpEnergyPoint.h"

#include "mEDEA-sp/include/MedeaSpSharedData.h"

class World;

class MedeaSpWorldObserver : public WorldObserver
{
	private:
		void updateExperimentalSettings(); // check and update (only if required) experimental setting.
		void updateEnvironmentResources(); //update all energypoint stored in __energyPoints 	
		void updateAllAgentsEnergyLevel();
		double forageReward(double G, double Q_E );
		static double _yCoordinates[14];//store 14 available position drawing merely an 8 with 200px between each position
		static double _xCoordinates[14];//
 		static int _order0[16];		//used to know all successive position the sun will have 
 		static int _order1[16];
		int _posNum;			//timer to get actual position of the sun (variyng between 0 and _orderX.size()
		bool firstIteration;
		
	protected:
		int _generationCount;
		int _lifeIterationCount;
		std::vector<MedeaSpEnergyPoint*> * coopEnergyPoints;

	public:
		MedeaSpWorldObserver( World *__world );
		~MedeaSpWorldObserver();
		void reset();
		void step();
		void setupNetwork(int sparsity);
		int yInCircle(int x,int radius,int xCenter,int yCenter);//with an x given, return an random y in the circle C(xCenter,yCenter) with radius=radius
		int getLifeIterationCount();
		std::vector<MedeaSpEnergyPoint*> * getEnergyPoints();
		MedeaSpEnergyPoint * getEnergyPoints(int i);
};

#endif
