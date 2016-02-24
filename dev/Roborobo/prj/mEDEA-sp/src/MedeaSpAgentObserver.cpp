/*
 *  MedeaSpAgentObserver.cpp
 *  Roborobo
 *
 *  imported from Jean-Marc on 15/12/09
 *  current dev: Nicolas on 1/4/2009
 *
 */


#include "mEDEA-sp/include/MedeaSpAgentObserver.h"

#include "World/World.h"
#include "Utilities/Misc.h"
#include "RoboroboMain/roborobo.h"
#include "mEDEA-sp/include/MedeaSpPerceptronControlArchitecture.h"
#include <cmath>


#include "mEDEA-sp/include/MedeaSpWorldObserver.h"


// *** *** *** *** ***


MedeaSpAgentObserver::MedeaSpAgentObserver( RobotAgentWorldModel *__wm )
{
	_wm = (MedeaSpAgentWorldModel*)__wm;

	_wm->_minValue = -1.0;
	_wm->_maxValue = 1.0;
	_wm->_currentSigma = MedeaSpSharedData::gSigmaRef;
	_wm->setLifeTime(1);
	_wm->setWaitForGenome(false);
	_wm->setActiveStatus(true);
	gProperties.checkAndGetPropertyValue("nbHiddenNeurons",&_wm->_nbHiddenNeurons,true);

	_wm->resetActiveGenome();
	_wm->setEnergyFound(0.0);

	if ( gVerbose )
	{
		std::cout << "robot #" << _wm->_agentId << "\n" ;	
	}
}

MedeaSpAgentObserver::~MedeaSpAgentObserver()
{
	// nothing to do.
}

void MedeaSpAgentObserver::reset()
{
	// nothing to do 
}

void MedeaSpAgentObserver::step()
{
	// debug verbose
	if ( gVerbose && gInspectAgent && gAgentIndexFocus == _wm->_agentId )
	{
		// 		std::cout << "target: " << _wm->getEnergyPointDirectionAngleValue() << std::endl;
	}

	// at the end of a generation
	if( 
			(_wm->getLifeTime() >= MedeaSpSharedData::gEvaluationTime && _wm->getWaitForGenome() && !(_wm->getActiveStatus()))
			||
			(_wm->getLifeTime() >= MedeaSpSharedData::gEvaluationTime && _wm->getActiveStatus())
	  ) 
	{

		/**
		 * Mechanism to print the values of the energy counters :
		 * 	It occurs when the state of an active robot change ie :
		 * 	1. When a robot Die (ie run out of energy)
		 * 	2. At the end of a generation.
		 * The following lines implement the second part, the first part is done when a agent die (in WorldObserver)
		 * */
		if(_wm->getActiveStatus() ){
			_wm->resetEnergyCounter();
		}


		checkGenomeList(); //here we look if the genome list is empty. If yes, the robot will wait again during a generation, 
		_wm->setLifeTime(0);//if not the robot will be activated and able to move again. a both case it'll stay in this state during a generation, that's why lifetime is set back top 0.

	}

	// at the end of the dead time (maby redondancy between control variables), the robot state should be in a listened mode (waitforgenome)
	if(_wm->getLifeTime() >= (MedeaSpSharedData::gEvaluationTime + rand()%10) && !(_wm->getWaitForGenome()) && !(_wm->getActiveStatus()))
	{
		_wm->setWaitForGenome(true);
		_wm->setLifeTime(0);
	}

	//handle the maturity concept
	//
	if( _wm->getActiveStatus() && _wm->getMaturity() > 0)
	{
		_wm->setMaturity(_wm->getMaturity()+1);
		if(_wm->getMaturity() > MedeaSpSharedData::gEvaluationTime+1 )
			_wm->setMaturity(0); //the robot will be able to spread his genome again

	}

	//fitness computed as soon as the robot is active
	if(_wm->getActiveStatus() == true){
		if (_wm->vectorFitnessesSize() <= 100)
		{

			_wm->vectorFitnessesPush(_wm->getEnergyFound());
		}
		else
		{
			_wm->computeFitness();
		}
	}

	// broadcast only if agent is active and mature 
	if ( _wm->getActiveStatus() == true && _wm->getMaturity()<=0)  	
	{
		for (int i = 0 ; i < gAgentCounter ; i++)
		{
			if ( ( i != _wm->_agentId ) && ( gRadioNetworkArray[_wm->_agentId][i] ) ) //&& (_wm->getEnergyLevel() > 0.0) ) --> always true as status is active
			{
				MedeaSpAgentObserver* targetAgentObserver = dynamic_cast<MedeaSpAgentObserver*>(gWorld->getAgent(i)->getObserver());
				if ( ! targetAgentObserver )
				{
					std::cerr << "Error from robot " << _wm->_agentId << " : the observer of robot " << i << " isn't a SwarmOnlineObserver" << std::endl;
					exit(1);
				}

				if((targetAgentObserver->_wm->getActiveStatus() ) || targetAgentObserver->_wm->getWaitForGenome())
				{
					if ( MedeaSpSharedData::gDynamicSigma == true )
					{
						float dice = float(rand() %100) / 100.0;
						float sigmaSendValue = 0.0;
						if ( ( dice >= 0.0 ) && ( dice < MedeaSpSharedData::gProbAdd) )
						{
							sigmaSendValue = _wm->_currentSigma * ( 1 + MedeaSpSharedData::gDynaStep );
							if (sigmaSendValue > MedeaSpSharedData::gSigmaMax)
							{
								sigmaSendValue = MedeaSpSharedData::gSigmaMax;
							}
						}
						else if ( ( dice >= MedeaSpSharedData::gProbAdd ) && ( dice < MedeaSpSharedData::gProbAdd+MedeaSpSharedData::gProbSub) )
						{
							sigmaSendValue = _wm->_currentSigma * ( 1 - MedeaSpSharedData::gDynaStep );
							if (sigmaSendValue < MedeaSpSharedData::gSigmaMin)
							{
								sigmaSendValue = MedeaSpSharedData::gSigmaMin;
							}
						}
						else
						{
							std::cerr << "Error : In SwarmOnlineObserver, the rand value is out of bound. The sum of MedeaSpSharedData::gProbRef and MedeaSpSharedData::gProbMax is probably not equal to one" << std::endl;
							exit(1);
						}
						targetAgentObserver->writeGenome(_wm->_currentGenome, _wm->_agentId + 1000 * _wm->getDateOfBirth(),sigmaSendValue,_wm->getFitness());
					}
					else
					{
						targetAgentObserver->writeGenome(_wm->_currentGenome, _wm->_agentId + 1000 * _wm->getDateOfBirth() , _wm->_currentSigma,_wm->getFitness());
					}
				}
			}
		}
	}

	_wm->setLifeTime(_wm->getLifeTime()+1);
}



void MedeaSpAgentObserver::checkGenomeList()
{


	if (_wm->_agentId == gAgentIndexFocus && gVerbose) // debug
	{
		std::cout << "agent #" << gAgentIndexFocus << " is renewed" << std::endl;
		std::cout << "agent #" << gAgentIndexFocus << " imported " << _wm->_genomesList.size() << " genomes. Energy is " << _wm->getEnergyLevel() << ". Status is "  << _wm->getActiveStatus() << "." <<std::endl;
	}


	// note: at this point, agent got energy, wether because it was revived or because of remaining energy.
	if (_wm->_genomesList.size() > 0) 
	{
		// case: 1+ genome(s) imported, random pick.

		_wm->setDateOfBirth(gWorld->getIterations());
		if((int)MedeaSpSharedData::gTournamentSize < 1) pickRandomGenome();
		else elitSelection();
		_wm->setWaitForGenome(false); // !N.20100407 : revive takes imported genome if any
		_wm->setActiveStatus(true);
		// 		_wm->setRobotLED_status(true);
		//Print the new genome on the logFile
		//gLogFile << gWorld->getIterations() <<" : "<< _wm->_agentId << " use "<<_wm->getAbilityToForage();

		//gLogFile << " at "<<_wm->getXReal()<< std::endl;
	}
	else
	{

		// case: no imported genome - wait for new genome.

		_wm->resetActiveGenome(); // optional -- could be set to zeroes.
		_wm->setWaitForGenome(true); // inactive robot *must* import a genome from others (ie. no restart).

		_wm->setActiveStatus(false);//The robot is waiting for genome but not active yet
	}

}



void MedeaSpAgentObserver::pickRandomGenome()
{
	if(_wm->_genomesList.size() != 0)//optional, should always be true : pickRandomGenome should be called only when liste>0
	{
		int randomIndex = rand()%_wm->_genomesList.size();
		std::map<int, std::vector<double> >::iterator it = _wm->_genomesList.begin();
		while (randomIndex !=0 )
		{
			it ++;
			randomIndex --;
		}

		_wm->_currentGenome = (*it).second;
		if ( MedeaSpSharedData::gDynamicSigma == true )
		{
			mutateWithBouncingBounds(_wm->_sigmaList[(*it).first]);
		}
		else
		{
			mutateWithBouncingBounds(-1.00);
		}

		_wm->setNewGenomeStatus(true); 
		_wm->setFatherId((*it).first);

		//gLogFile << gWorld->getIterations() << " : " << _wm->_agentId + 1000 * _wm->getDateOfBirth()  << " take " << _wm->getFatherId()<<std::endl;
		if (_wm->_agentId == 1 && gVerbose) // debug
			std::cout << "  Sigma is " << _wm->_sigmaList[(*it).first] << "." << std::endl;


		_wm->_genomesList.clear();
	}
	//never reached
}


void MedeaSpAgentObserver::elitSelection()
{
	if(_wm->_genomesList.size() != 0)//optional, should always be true : pickRandomGenome should be called only when liste>0
	{
		std::map<int, std::vector<double> > tournamentListGenome;
		std::map<int, double > tournamentListFitness;
		std::cout<<"size???"<<(int)MedeaSpSharedData::gTournamentSize<<std::endl;
		unsigned int aimedSize = std::min((int)MedeaSpSharedData::gTournamentSize,(int)_wm->_genomesList.size());
		//unsigned int aimedSize = std::min(1,(int)_wm->_genomesList.size());
		while ( tournamentListGenome.size() < aimedSize)
		{
			int randomIndex = rand()%_wm->_genomesList.size();
			std::map<int, std::vector<double> >::iterator it = _wm->_genomesList.begin();
			while (randomIndex !=0 )
			{
				it ++;
				randomIndex --;
			}
			tournamentListGenome[(*it).first] = (*it).second;
			tournamentListFitness[(*it).first] = _wm->_fitnessList[(*it).first];
			_wm->_genomesList.erase((*it).first);
		}

		double bestFitness = (*tournamentListFitness.begin()).second;
		int idBest = (*tournamentListFitness.begin()).first;
		for (std::map<int, double>::iterator it = tournamentListFitness.begin(); it != tournamentListFitness.end() ; it++)
		{
			if ( (*it).second > bestFitness )
			{
				bestFitness = (*it).second;
				idBest = (*it).first;
			}
		}
		_wm->_currentGenome = tournamentListGenome[idBest];

		if ( MedeaSpSharedData::gDynamicSigma == true )
		{
			mutateWithBouncingBounds(_wm->_sigmaList[idBest]);
		}
		else
		{
			mutateWithBouncingBounds(-1.00);
		}

		_wm->setNewGenomeStatus(true); 
		_wm->setFatherId(idBest);

		//gLogFile << gWorld->getIterations() << " : " << _wm->_agentId + 1000 * _wm->getDateOfBirth()  << " take " << _wm->getFatherId()<<std::endl;
		if (_wm->_agentId == 1 && gVerbose) // debug
			std::cout << "  Sigma is " << _wm->_sigmaList[idBest] << "." << std::endl;


		_wm->_genomesList.clear();
		_wm->_fitnessList.clear();
	}
}

void MedeaSpAgentObserver::writeGenome(std::vector<double> genome, int senderId, float sigma, float fitness)
{

	_wm->_fitnessList[senderId] = fitness;
	_wm->_genomesList[senderId] = genome;
	if ( MedeaSpSharedData::gDynamicSigma == true)
	{
		_wm->_sigmaList[senderId] = sigma;
	}
}


void MedeaSpAgentObserver::mutateWithBouncingBounds( float sigma)
{
	_wm->_genome.clear();

	if ( MedeaSpSharedData::gDynamicSigma == true)
	{
		_wm->_currentSigma = sigma;
	}
	else
	{
		float randValue = float(rand() %100) / 100.0;
		if ( ( randValue >= 0.0 ) && ( randValue < MedeaSpSharedData::gProbRef) )
		{
			_wm->_currentSigma = MedeaSpSharedData::gSigmaRef;
		}
		else if ( ( randValue >= MedeaSpSharedData::gProbRef ) && ( randValue < MedeaSpSharedData::gProbMax+MedeaSpSharedData::gProbRef) )
		{
			_wm->_currentSigma = MedeaSpSharedData::gSigmaMax;
		}
		else
		{
			std::cerr << "Error : In SwarmOnlineObserver, the rand value is out of bound. The sum of MedeaSpSharedData::gProbRef and MedeaSpSharedData::gProbMax is probably not equal to one" << std::endl;
			exit(1);
		}
	}

	for (unsigned int i = 0 ; i != _wm->_currentGenome.size() ; i++ )
	{
		double value = _wm->_currentGenome[i] + getGaussianRand(0,_wm->_currentSigma);
		// bouncing upper/lower bounds
		if ( value < _wm->_minValue )
		{
			double range = _wm->_maxValue - _wm->_minValue;
			double overflow = - ( (double)value - _wm->_minValue );
			overflow = overflow - 2*range * (int)( overflow / (2*range) );
			if ( overflow < range )
				value = _wm->_minValue + overflow;
			else // overflow btw range and range*2
				value = _wm->_minValue + range - (overflow-range);
		}
		else
		    if ( value > _wm->_maxValue )
			{
				double range = _wm->_maxValue - _wm->_minValue;
				double overflow = (double)value - _wm->_maxValue;
				overflow = overflow - 2*range * (int)( overflow / (2*range) );
				if ( overflow < range )
					value = _wm->_maxValue - overflow;
				else // overflow btw range and range*2
					value = _wm->_maxValue - range + (overflow-range);
			}

		_wm->_genome.push_back(value);
	}

	_wm->_currentGenome = _wm->_genome;

}


