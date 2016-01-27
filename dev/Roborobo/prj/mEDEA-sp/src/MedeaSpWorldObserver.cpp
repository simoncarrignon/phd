/*
 *  MedeaSpWorldObserver.cpp
 *  roborobo-online
 *
 *  Created by Nicolas on 24/05/10.
 *  Copyright 2010.
 *
 */

#include "Observers/AgentObserver.h"
#include "Observers/WorldObserver.h"

#include "mEDEA-sp/include/MedeaSpWorldObserver.h"
#include "mEDEA-sp/include/MedeaSpNetworkGenerator.h"

#include "World/World.h"
#include <math.h>

MedeaSpWorldObserver::MedeaSpWorldObserver( World* __world ) : WorldObserver( __world )
{

	_world = __world;
	

	// ==== two-suns specific
	
	gProperties.checkAndGetPropertyValue("gSunLifetime",&MedeaSpSharedData::gSunLifetime,true);


	// ==== loading project-specific properties 

	gProperties.checkAndGetPropertyValue("gSwarmOnlineObsUsed",&MedeaSpSharedData::gSwarmOnlineObsUsed,true);
	gProperties.checkAndGetPropertyValue("gDynamicSigma",&MedeaSpSharedData::gDynamicSigma,true);
	gProperties.checkAndGetPropertyValue("gSigmaMin",&MedeaSpSharedData::gSigmaMin,true);
	gProperties.checkAndGetPropertyValue("gProbAdd",&MedeaSpSharedData::gProbAdd,true);
	gProperties.checkAndGetPropertyValue("gProbSub",&MedeaSpSharedData::gProbSub,true);
	gProperties.checkAndGetPropertyValue("gDynaStep",&MedeaSpSharedData::gDynaStep,true);
	gProperties.checkAndGetPropertyValue("gSigmaRef",&MedeaSpSharedData::gSigmaRef,true);
	gProperties.checkAndGetPropertyValue("gSigmaMax",&MedeaSpSharedData::gSigmaMax,true);
	gProperties.checkAndGetPropertyValue("gProbRef",&MedeaSpSharedData::gProbRef,true);
	gProperties.checkAndGetPropertyValue("gProbMax",&MedeaSpSharedData::gProbMax,true);
	gProperties.checkAndGetPropertyValue("gEvaluationTime",&MedeaSpSharedData::gEvaluationTime,true);
	gProperties.checkAndGetPropertyValue("gDriftEvaluationRate",&MedeaSpSharedData::gDriftEvaluationRate,true);
	gProperties.checkAndGetPropertyValue("gInitLock",&MedeaSpSharedData::gInitLock,true);
	gProperties.checkAndGetPropertyValue("gDriftLock",&MedeaSpSharedData::gDriftLock,true);
	gProperties.checkAndGetPropertyValue("gMaxKeyRange",&MedeaSpSharedData::gMaxKeyRange,true);
	gProperties.checkAndGetPropertyValue("gDeltaKey",&MedeaSpSharedData::gDeltaKey,true);
	gProperties.checkAndGetPropertyValue("gSynchronization",&MedeaSpSharedData::gSynchronization,true);

	gProperties.checkAndGetPropertyValue("gExperimentNumber",&MedeaSpSharedData::gExperimentNumber,true);
	gProperties.checkAndGetPropertyValue("gExperiment1_genStart",&MedeaSpSharedData::gExperiment1_genStart,true);
	gProperties.checkAndGetPropertyValue("gExperiment2_genStart",&MedeaSpSharedData::gExperiment2_genStart,true);

	gProperties.checkAndGetPropertyValue("g_xStart_EnergyZone",&MedeaSpSharedData::g_xStart_EnergyZone,true);
	gProperties.checkAndGetPropertyValue("g_yStart_EnergyZone",&MedeaSpSharedData::g_yStart_EnergyZone,true);
	gProperties.checkAndGetPropertyValue("g_xEnd_EnergyZone",&MedeaSpSharedData::g_xEnd_EnergyZone,true);
	gProperties.checkAndGetPropertyValue("g_yEnd_EnergyZone",&MedeaSpSharedData::g_yEnd_EnergyZone,true);

	gProperties.checkAndGetPropertyValue("gZoneEnergy_maxHarvestValue",&MedeaSpSharedData::gZoneEnergy_maxHarvestValue,true);
	gProperties.checkAndGetPropertyValue("gZoneEnergy_minHarvestValue",&MedeaSpSharedData::gZoneEnergy_minHarvestValue,true);
	gProperties.checkAndGetPropertyValue("gZoneEnergy_maxFullCapacity",&MedeaSpSharedData::gZoneEnergy_maxFullCapacity,true);
	gProperties.checkAndGetPropertyValue("gZoneEnergy_saturateCapacityLevel",&MedeaSpSharedData::gZoneEnergy_saturateCapacityLevel,true);
	
	gProperties.checkAndGetPropertyValue("gB",&MedeaSpSharedData::gB,true);	gProperties.checkAndGetPropertyValue("gN",&MedeaSpSharedData::gN,true);

	gProperties.checkAndGetPropertyValue("gDeadTime",&MedeaSpSharedData::gDeadTime,true);
	gProperties.checkAndGetPropertyValue("gEnergyMax",&MedeaSpSharedData::gEnergyMax,true);
	gProperties.checkAndGetPropertyValue("gEnergyInit",&MedeaSpSharedData::gEnergyInit,true);
	
	gProperties.checkAndGetPropertyValue("gEnergyRevive",&MedeaSpSharedData::gEnergyRevive,true);
// 	gProperties.checkAndGetPropertyValue("gNbTypeResource",&MedeaSpSharedData::gEnergyRevive,true);
	gProperties.checkAndGetPropertyValue("gMaxPenalizationRate",&MedeaSpSharedData::gMaxPenalizationRate,true);
	if ( MedeaSpSharedData::gMaxPenalizationRate < 0 || MedeaSpSharedData::gMaxPenalizationRate > 1 )
	{
		std::cerr << "gMaxPenalizationRate should be defined btw O and 1" << std::endl;
		exit(-1);
	}
	
	gProperties.checkAndGetPropertyValue("gDynamicRespawn",&MedeaSpSharedData::gDynamicRespawn,true); // forced, in this setup.
	
	gProperties.checkAndGetPropertyValue("gRandSun",&MedeaSpSharedData::gRandSun,true);
	
	gProperties.checkAndGetPropertyValue("gNbAllowedRobotsBySun",&MedeaSpSharedData::gNbAllowedRobotsBySun,true);
	gProperties.checkAndGetPropertyValue("gNoEnergy",&MedeaSpSharedData::gNoEnergy,true);
	gProperties.checkAndGetPropertyValue("gNoDenPenTime",&MedeaSpSharedData::gNoDenPenTime,true);
	
	gProperties.checkAndGetPropertyValue("gTournamentSize",&MedeaSpSharedData::gTournamentSize,true);
	gProperties.checkAndGetPropertyValue("gExperimentNoMovements",&MedeaSpSharedData::gExperimentNoMovements,true);
// 	MedeaSpSharedData::gSparsity;
	
	// ====================================
//	Line commented in order to allow setup network test
	if ( !gRadioNetwork)
	{
		gProperties.checkAndGetPropertyValue("gSparsity",&MedeaSpSharedData::gSparsity,true);
	}
	
	if ( !MedeaSpSharedData::gSwarmOnlineObsUsed)
	{
		std::cout << "Error : gSwarmOnlineObsUsed == false. The swarm online observer need some variables. Define this option to true or use another observer" << std::endl;
		exit(1);
	}

	if ( !gEnergyMode )
	{
		std::cout << "Error : gEnergyMode should be true to use SwarmOnlineObserver" << std::endl;
		exit(1);
	}
	// * iteration and generation counters
	
	_posNum=0;
	_lifeIterationCount = -1;
	_generationCount = -1;
// 	coopEnergyPoints = std::vector<MedeaSpEnergyPoint*>(gMaxEnergyPoints);

	std::cout << std::endl << "#### Experiment no.0 starts now. ####" << std::endl;
	firstIteration=true;
	
}

//in a better world that attribute should be set through the properties file
double MedeaSpWorldObserver::_xCoordinates[14] = {60,152.28,352.28,500.00,300.5633,699.4367,648,848,960,848,648,500.00,352.28,152.28};

double MedeaSpWorldObserver::_yCoordinates[14] = {250,400.00,400.00,265.18,250.0000,250.0000,400,400,250,100,100,235.61,100.00,100.00};

// int MedeaSpWorldObserver::_order0[20] = {3,4,3,5,11,10,9,8,7,6,3,5,3,4,11,12,13,0,1,2};
// int MedeaSpWorldObserver::_order1[20] = {11,5,11,4,3,2,1,0,13,12,11,4,11,5,3,6,7,8,9,10};

int MedeaSpWorldObserver::_order0[16] = {3,4,11,10,9,8,7,6,3,5,11,12,13,0,1,2};
int MedeaSpWorldObserver::_order1[16] = {11,5,3,2,1,0,13,12,11,4,3,6,7,8,9,10};


// int MedeaSpWorldObserver::_order0[12] = {0,1,2,4,12,13,0,1,2,4,12,13};
// int MedeaSpWorldObserver::_order1[12] = {8,9,10,5,6,7,8,9,10,5,6,7};


MedeaSpWorldObserver::~MedeaSpWorldObserver()
{
	while (!coopEnergyPoints->empty())
	{
		delete coopEnergyPoints->back();
		coopEnergyPoints->pop_back();
	}
	// nothing to do.
}

void MedeaSpWorldObserver::reset()
{
	if(!gRadioNetwork){
	    
		MedeaSpNetworkGenerator  ng= MedeaSpNetworkGenerator(MedeaSpSharedData::gSparsity);
		ng.buildRandomNetwork();
		ng.writeGraphFile();
	}
}



int MedeaSpWorldObserver::yInCircle(int x,int radius,int xCenter,int yCenter)
{
	int sign=-1;
	if(rand()%2 == 1)sign=1;
	return (sign*sqrt(sqrt(pow(radius,2)-pow((x-xCenter),2)))+(yCenter)-sign*rand()%radius);
}

std::vector<MedeaSpEnergyPoint*>* MedeaSpWorldObserver::getEnergyPoints()
{
    return coopEnergyPoints;
    
}    

MedeaSpEnergyPoint* MedeaSpWorldObserver::getEnergyPoints(int i)
{
    return coopEnergyPoints->at(i);
}

void MedeaSpWorldObserver::step()
{


	if(firstIteration){
		
		firstIteration=false;
		gEnergyPoints.empty();
		
		// setting up SUN locations
		int x0,x1,y0,y1;
		if(!MedeaSpSharedData::gRandSun)
		{
			//if the sun dont move randomly :

			//two case, the suns move but not randomly so they follow the order record in order0|1
			x0=_xCoordinates[_order0[0]];
			y0=_yCoordinates[_order0[0]];
			x1=_xCoordinates[_order1[0]];
			y1=_yCoordinates[_order1[0]];

			if(MedeaSpSharedData::gExperimentNoMovements){
				//the suns don't move. In that case their position and size will depend on gExperimentNumber
				switch (MedeaSpSharedData::gExperimentNumber )
				{
					case 0:
						gEnergyPointRadius=450;
						gMaxRadioDistanceToSquare=40*40;
						x0=470+10;x1=530+10;
						y0=250;y1=250;
						break;
					case 1:
						gEnergyPointRadius=4500;
						gMaxRadioDistanceToSquare=8*8;
						x0=470+10;x1=530+10;
						y0=250;y1=250;
						break;
					case 3:
						gEnergyPointRadius=450;
						gMaxRadioDistanceToSquare=40*40;
						x0=470+10;x1=530+10;
						y0=250;y1=250;
						break;
					case 2:
						gEnergyPointRadius=500;
						gMaxRadioDistanceToSquare=8*8;
						x0=0+20;x1=1000;
						y0=250;y1=250;
						break;
					case 4:
						gEnergyPointRadius=515;
						gMaxRadioDistanceToSquare=40*40;
						x0=0+20;x1=1000;
						y0=250;y1=250;
						break;

				}
			}

		}
		else
		{
			//if the suns move randomly, they start from random place
			x0=10 + (rand() % 990 +0 );
			y0=(rand() % 490)+0;
			x1=10 + (rand() % 990  - 0);
			y1=10 +(rand() % 490)+0;
		}
		
		Point2d positionSun0(x0,y0 );
		Point2d positionSun1(x1,y1 );

		coopEnergyPoints=new std::vector<MedeaSpEnergyPoint*>();
		coopEnergyPoints->push_back(new MedeaSpEnergyPoint(0));
		InanimateObject * pInaObj = (InanimateObject*) coopEnergyPoints->back();
		gWorld->addObject(pInaObj);
		coopEnergyPoints->push_back(new MedeaSpEnergyPoint(1));
		pInaObj = (InanimateObject*) coopEnergyPoints->back();
		gWorld->addObject(pInaObj);
		
		
		for(std::vector<MedeaSpEnergyPoint*>::iterator it= coopEnergyPoints->begin(); it!=coopEnergyPoints->end();it++){
// 			(*it)->hide();
			if((*it)->getType() == 1)
				(*it)->setPosition(positionSun1); 
			else
				(*it)->setPosition(positionSun0); 
			(*it)->display();
			(*it)->setNHarverst(0);
			(*it)->setFixedLocationStatus(false);
		}

		int l=0;//used to put robots on a grid
		int L=0;
		if(MedeaSpSharedData::gExperimentNoMovements)
		{
			for(int i =0 ; i!=gAgentCounter;i++)
			{


				MedeaSpAgentWorldModel * _wm = dynamic_cast<MedeaSpAgentWorldModel*>(gWorld->getAgent(i)->getWorldModel());

				_wm->_yReal=250;
				int radius=sqrt(gMaxRadioDistanceToSquare);
				switch (MedeaSpSharedData::gExperimentNumber)
				{
					case 0:
						_wm->_xReal=510 -50+l*5;
						_wm->_yReal=250 + 50.0/2.0 -L*5;
						l++;
						// 				_wm->_xReal=(510-radius)+ rand() % (2*radius);
						// 				_wm->_yReal=yInCircle(_wm->_xReal,radius,510,250);//-rand()%radius;
						if(l>=10){l=0;L++;}
						if(L>=10){L=0;}
						break;
					case 1:
						_wm->_xReal=50; //I change in 2016 like that all agent are on the same point. BECAUSE I DONT CARRRE!
						break;
					case 2:
						_wm->_xReal=i*int(radius)+510-(radius*99)/2;//5+(1000/2-((100/2-1)*5+100/2*5));
						break;
					case 3:
					case 4:
						if(i<=48)
						{
							//35 is for the width of the square (7robots*5px), and 10 is the length beetwen the square and the "eplorateur" robot allow the upper left robot of the square to see the expl rob
							_wm->_xReal=(510 - radius/2)-35-10+l*5;
							_wm->_yReal=(250 + 35.0/2.0 - 2 )-L*5;
							l++;
							//std::cout<<l<<std::endl;
							if(l>=7){l=0;L++;}
							if(L>=7){L=0;}
							//put robots randomly in circle
							//_wm->_xReal= (510 - radius/2) - 2*radius + (2*rand()%radius);
							//_wm->_yReal=yInCircle(_wm->_xReal,radius,510-radius/2-2*radius,250); 
						}
						if(i==49){_wm->_xReal= 510 - radius/2 ; }
						if(i==50){_wm->_xReal= 510 + radius/2 ;l=0;}
						if(i>50)
						{
							_wm->_xReal=(510 + radius/2)+35+10-l*5;
							_wm->_yReal=(250 + 35.0/2.0 - 2)-L*5;
							l++;
							if(l>=7){l=0;L++;}
							if(L>=7){L=0;}
							//put robots randomly in circle
							//_wm->_xReal= (510 +  radius/2) + 2*radius + (2*rand()%radius); 
							//_wm->_yReal=yInCircle(_wm->_xReal,radius,510+radius/2+2*radius,250); 
						}
						break;

				}
			}


		}
	}

	// ***
	// * update iteration and generation counters + switch btw experimental setups if required
	// ***
	
	_lifeIterationCount++;

	if( _lifeIterationCount >= MedeaSpSharedData::gEvaluationTime ) // print mEDEA state.
	{
		// * monitoring: count number of active agents.
		//TODO Possibly a good place to handle the logFile

		int activeCount = 0;
		int r0=0;
		int r1=0;
		int both=0;
		double meanFitness=0.0;
		for ( int i = 0 ; i != gAgentCounter ; i++ )
		{
			MedeaSpAgentWorldModel * _wm = (dynamic_cast<MedeaSpAgentWorldModel*>(gWorld->getAgent(i)->getWorldModel()));
			if ( _wm->getActiveStatus() == true )
			{
				activeCount++;
				meanFitness+=_wm->getFitness();
				std::cout<<"fitness "<<meanFitness;
				if( forageReward(_wm->getAbilityToForage(),1) > 0 && forageReward(_wm->getAbilityToForage(),0) > 0)
					both++;
				else if( forageReward(_wm->getAbilityToForage(),0) > 0)
					r0++;
				else if( forageReward(_wm->getAbilityToForage(),1) > 0)
					r1++;
				
			}
		}

		if ( !gVerbose )
		{
			std::cout << "[" << activeCount << "]";
		}
	
		gLogFile << gWorld->getIterations() << " : activeCount " << activeCount <<" "<<both<<" "<<r0<<" "<<r1<<" "<< meanFitness/100 << std::endl;
		
		if(activeCount<=0){
		 	gLogFile.close();
			std::cout<<"-->extinction"<<gLogFilename<<std::endl;
			
			exit(0);
			
		}
		
		// * monitor and log orientation and distance to center for all agents
		
		// build heatmap
		
		//int heatmapSize = 1000; // arbitrary, but should be enough to get precise view
		//int maxDistance = sqrt ( gAreaWidth*gAreaWidth + gAreaHeight*gAreaHeight ) / 2.0 ; // distance max to center.
		//
		//int *distanceHeatmap;
		//distanceHeatmap = new int[heatmapSize];
		//int *orientationHeatmap;
		//orientationHeatmap = new int[heatmapSize];

		//for (int i = 0 ; i != heatmapSize ; i++ )
		//{
		//	distanceHeatmap[i] = 0;
		//	orientationHeatmap[i] = 0;
		//}
		//	
		//double xRef = gAreaWidth / 2.0 ;
		//double yRef = gAreaHeight / 2.0 ;

		//for ( int i = 0 ; i != gAgentCounter ; i++ )
		//{
		//	MedeaSpAgentWorldModel *wm = (dynamic_cast<MedeaSpAgentWorldModel*>(gWorld->getAgent(i)->getWorldModel()));
		//	
		//	
		//	if ( wm->getActiveStatus() == true ) // only active agents
		//	{
		//		double dist = getEuclidianDistance( xRef, yRef, wm->_xReal, wm->_yReal );
		//		int indexDist = (int)dist * heatmapSize / maxDistance; // normalize within heatmap bounds
		//		distanceHeatmap[indexDist]++;
		//		
		//		// monitor orientationHeatmap

		//		double orient = acos ( ( wm->_xReal - xRef ) / (double)dist );
		//		if ( wm->_yReal - yRef > 0 ) // [trick] why ">0" ?  : it should be <0, but as the 2D-display norm for the coordinate system origin is upper-left (and not bottom-left), the sign is inversed.
		//		{
		//			orient = -orient;
		//		}
		//		
		//		int indexOrient = ( orient + M_PI ) * heatmapSize / (2.0 * M_PI);
		//		orientationHeatmap[heatmapSize-1-((indexOrient+((heatmapSize*3)/4))%heatmapSize)]++; // index is such that list ordering is as follow: [South-West-North-East-South]
		//	}
		//}		
		//
		//
		//// update log file
		//
		//std::string str_agentDistancesToRef ="";
		//std::string str_agentOrientationsToRef = "";
		//
		//for (int i = 0 ; i != heatmapSize ; i++ )
		//{
		//	str_agentDistancesToRef += convertToString(distanceHeatmap[i]);
		//	str_agentDistancesToRef += ",";
		//	str_agentOrientationsToRef += convertToString(orientationHeatmap[i]);
		//	str_agentOrientationsToRef += ",";
		//}
		//
		//		
		//delete [] distanceHeatmap;
		//delete [] orientationHeatmap;

		// * update iterations and generations counters

		_lifeIterationCount = 0;
		_generationCount++;
		

	}
	// * Switch btw experiment setups, if required	
	
	updateExperimentalSettings();

	// * Update environment status wrt. nature and availability of energy resources (update at each iteration)

	updateEnvironmentResources();

	// * update energy level for each agents (ONLY active agents)
	
	updateAllAgentsEnergyLevel();
	
	// prepape and take screenshot of ultimate iteration
	
	if ( gWorld->getIterations() == gMaxIt-2 )
	{
		gDisplayMode = 0;
		gDisplaySensors = true; // prepape for next it.
	}
// 	else
// 	{
// 		if ( gWorld->getIterations() == gMaxIt-1 )
// // 			saveScreenshot("lastIteration");
// 	}
}



// ***
// * Check and update (ONLY IF REQUIRED) experimental setup.
// ***

void MedeaSpWorldObserver::updateExperimentalSettings()
{
// 	if(gWorld->getIterations() > 100000)gEnergyMode=true;
// 	else gEnergyMode=false;
}

//Mapping function givin the fitness of a given genotype G for a given ressource Q_E
double  MedeaSpWorldObserver::forageReward(double G, double Q_E ){
	if(Q_E == 0)Q_E=-1.0;
	double b=MedeaSpSharedData::gB;
	double n=MedeaSpSharedData::gN;
	double reward ;
	bool th=true;
	if(th)
	{
		reward=((tanh(b*(G-Q_E*n/100)*Q_E)+1)/(tanh(b)))/2*gEnergyPointValue; 
	}
	else
	{
		n=n;
		b=b/100;
		double C = (b * exp(n) - exp(-n))/(1-b);
		reward = (exp(n*G*Q_E)+C)/(exp(n)+C)*gEnergyPointValue;
	}
	if(reward<0.01) reward = 0;
	return reward; 
}

// ***
// * Update environment status wrt. nature and availability of energy resources (update at each iteration)
// ***
void MedeaSpWorldObserver::updateEnvironmentResources()
{

	if ( gWorld->getIterations() % ( int(MedeaSpSharedData::gSunLifetime) ) == 0 && !MedeaSpSharedData::gExperimentNoMovements )
	{
		
		for(std::vector<MedeaSpEnergyPoint*>::iterator it = coopEnergyPoints->begin(); it != coopEnergyPoints->end(); it++)
		{
			(*it)->hide();
			(*it)->setNHarverst(0);
		}
		
		int x0=0,y0=0,x1=0,y1=0;
		
		if(MedeaSpSharedData::gRandSun)
		{
			x0=10 + (rand() % 990 +0 );//totally random
			y0=(rand() % 490)+0;
			x1=10 + (rand() % 990  - 0);
			y1=10 +(rand() % 490)+0;
			
			bool falseRandom =false;
			if(falseRandom){
				x1=550.0 + (rand() % (450)-10);//Random but in opposite sides
				y1=(rand() % 490)+10;
				x0=rand() % (450) +10 ;
				y0=(rand() % 490)+10;
			}
		}
		else 
		{
			x0=_xCoordinates[_order0[_posNum]];
			y0=_yCoordinates[_order0[_posNum]];
			x1=_xCoordinates[_order1[_posNum]];
			y1=_yCoordinates[_order1[_posNum]];
			_posNum++;
			if(_posNum>=12)_posNum=0;
		}  
		Point2d positionSun0(x0,y0);
		Point2d positionSun1(x1,y1);
		
		for(std::vector<MedeaSpEnergyPoint*>::iterator it = coopEnergyPoints->begin(); it != coopEnergyPoints->end(); it++)
		{
			if((*it)->getType() == 1)(*it)->setPosition(positionSun1); 
			else(*it)->setPosition(positionSun0); 
			(*it)->display();
		}
		
	}
	
	//update number of token available on the ressources
	for(std::vector<MedeaSpEnergyPoint*>::iterator it = coopEnergyPoints->begin(); it<coopEnergyPoints->end(); it++) 
	{
		if((*it)->getType()==1)
			(*it)->setQ_E(MedeaSpSharedData::gNbAllowedRobotsBySun);
		else
			(*it)->setQ_E(gAgentCounter-MedeaSpSharedData::gNbAllowedRobotsBySun);
	}
}


// * 
// * update energy level for each agents (ONLY active agents) (only in experimental setups featuring energy items)
// *
//TODO : randomize the order
void MedeaSpWorldObserver::updateAllAgentsEnergyLevel()
{	
	// --- Take from src/world.cpp
	// * create an array that contains shuffled indexes. Used afterwards for randomly update agents.
	//    This is very important to avoid possible nasty effect from ordering such as "agents with low indexes moves first"
	//    outcome: among many iterations, the effect of ordering is reduced.
	//    As a results, roborobo is turn-based, with sotchastic updates within one turn
	
        int shuffledIndex[gAgentCounter];

        for ( int i = 0 ; i < gAgentCounter ; i++ ) 
	    shuffledIndex[i] = i;
	
        for ( int i = 0 ; i < gAgentCounter-1 ; i++ ) // exchange randomly indexes with one other
		{	
            int r = i + (rand() % (gAgentCounter-i)); // Random remaining position.
            int tmp = shuffledIndex[i];
			shuffledIndex[i] = shuffledIndex[r]; 
			shuffledIndex[r] = tmp;
        }
        
        
	for ( int i = 0 ; i != gAgentCounter ; i++ ) // for each agent
	{
		MedeaSpAgentWorldModel *currentAgentWorldModel = dynamic_cast<MedeaSpAgentWorldModel*>(gWorld->getAgent(shuffledIndex[i])->getWorldModel());
		
		// * check energy level. Becomes inactive if zero.
		

		// * if active, check if agent harvests energy. 
		if(gWorld->getIterations() > MedeaSpSharedData::gNoEnergy){
			if ( currentAgentWorldModel->getActiveStatus() == true )
			{
				// * update agent energy (if needed) - agent should be on an active energy point location to get energy
				
				Point2d posRobot(currentAgentWorldModel->_xReal,currentAgentWorldModel->_yReal);
				for(std::vector<MedeaSpEnergyPoint*>::iterator it = coopEnergyPoints->begin(); it<coopEnergyPoints->end(); it++) 
				{
					if( (getEuclidianDistance (posRobot,(*it)->getPosition()) < gEnergyPointRadius) && (*it)->getActiveStatus())
					{
						double energyReachable =forageReward(currentAgentWorldModel->getAbilityToForage(),(*it)->getType());
						
						currentAgentWorldModel->setEnergyFound(energyReachable) ;

						if(gWorld->getIterations() > MedeaSpSharedData::gNoDenPenTime && energyReachable>0 )
						{
							(*it)->setQ_E((*it)->getQ_E()-1);
							if((*it)->getQ_E()<=0 ) energyReachable=0;
						}
						
						double energyAdded;
						// update energy level
						if(currentAgentWorldModel->getEnergyLevel() + energyReachable > MedeaSpSharedData::gEnergyMax)
						{
							currentAgentWorldModel->setEnergyLevel(MedeaSpSharedData::gEnergyMax);
							
							energyAdded=currentAgentWorldModel->getEnergyCounterOfOneRessource((*it)->getType()) + double(MedeaSpSharedData::gEnergyMax) - currentAgentWorldModel->getEnergyLevel();
							
							
						}
						else{
							currentAgentWorldModel->setEnergyLevel(currentAgentWorldModel->getEnergyLevel() + energyReachable);
							
							energyAdded=currentAgentWorldModel->getEnergyCounterOfOneRessource((*it)->getType()) + energyReachable ;
						}
						currentAgentWorldModel->setEnergyCounterOfOneRessource((*it)->getType(),energyAdded );
						
						currentAgentWorldModel->setDeltaEnergy(currentAgentWorldModel->getDeltaEnergy() + energyReachable);

					}
				}
			}
			
			
			
			// * update agent energy consumption -- if inactive, "revive" the agent (ie. it ran out of energy)
			
			// decrease the energyLevel and deltaEnergyLevel
			if ( currentAgentWorldModel->getEnergyLevel() > 0.0 && currentAgentWorldModel->getActiveStatus() == true ) 
			{
				currentAgentWorldModel->setEnergyLevel(currentAgentWorldModel->getEnergyLevel()-1); 
				
				/***
				 * Allopatric test
				 * Deprecated
				 **/
				bool allopatric = false;
				if(allopatric){
					if(currentAgentWorldModel->_xReal > 490 && currentAgentWorldModel->_xReal < 510){
		//				int mountainCost=0;
		//				
		//				mountainCost = 10000;//pow((1-(pow((currentAgentWorldModel->getEnergyLevel()-500),4)/pow(500,4))),1000)*40000;// pow((500-currentAgentWorldModel->getEnergyLevel())/100,100);
						// 					currentAgentWorldModel->resetActiveGenome();
						
						currentAgentWorldModel->_genomesList.clear();
						currentAgentWorldModel->setWaitForGenome(true);
						currentAgentWorldModel->setActiveStatus(false);
// 						currentAgentWorldModel->setRobotLED_status(false);
						currentAgentWorldModel->setLifeTime(0);
						if(currentAgentWorldModel->_xReal < 500) currentAgentWorldModel->_xReal=currentAgentWorldModel->_xReal - (rand() % 300);
						else 
							currentAgentWorldModel->_xReal=currentAgentWorldModel->_xReal+ (rand() % 300);
						// 					currentAgentWorldModel->setEnergyLevel(currentAgentWorldModel->getEnergyLevel() - mountainCost);				
							currentAgentWorldModel->_yReal=rand() % 200 + 10;
					}
				}
				/***
				 * -------------
				 ***/
			}
			currentAgentWorldModel->setDeltaEnergy(currentAgentWorldModel->getDeltaEnergy()-1); 
			
			
			// "revive" agent with empty genomes if ran out of energy.
			
			if  ( currentAgentWorldModel->getEnergyLevel()  <= 0  && currentAgentWorldModel->getActiveStatus() == true)
			{
				currentAgentWorldModel->resetEnergyCounter();
				currentAgentWorldModel->setMaturity(1);
				
				if (currentAgentWorldModel->_agentId == gAgentIndexFocus && gVerbose) // debug
				{
					std::cout << "agent #" << gAgentIndexFocus << " is revived (energy was 0)." << std::endl;
				}
				
				
				
				currentAgentWorldModel->resetActiveGenome();//inutile?
				
				currentAgentWorldModel->setEnergyLevel(MedeaSpSharedData::gEnergyRevive); 
				currentAgentWorldModel->setEnergyCounterOfOneRessource(currentAgentWorldModel->getEnergyCounter().size()-1,MedeaSpSharedData::gEnergyRevive);
				//---The robot is Dead (ie not listening for a genome)
				currentAgentWorldModel->setActiveStatus(false);
				currentAgentWorldModel->setWaitForGenome(false);
				currentAgentWorldModel->_genomesList.clear();
				currentAgentWorldModel->_fitnessList.clear();
				currentAgentWorldModel->_genomesList.empty(); 
				
				
			}
		}
	}	
}


int MedeaSpWorldObserver::getLifeIterationCount()
{
	return _lifeIterationCount;
}
