/*
 *  MedeaSpPerceptronControlArchitecture.cpp
 *  roborobo-online
 *
 *  imported from  Nicolas on 01/05/11
 *  current dev: Simon on may 2011
 *
 */

#include "mEDEA-sp/include/MedeaSpPerceptronControlArchitecture.h"

#include "World/World.h"

#include "Utilities/Misc.h"

#include <math.h>
#include <mEDEA-sp/include/MedeaSpWorldObserver.h>



MedeaSpPerceptronControlArchitecture::MedeaSpPerceptronControlArchitecture( RobotAgentWorldModel *__wm )
{
	_wm = (MedeaSpAgentWorldModel*)__wm;
	//_wm->_genome.resize(18);
	_iteration = 0;

	//_initialEnergy = 2*MedeaSpSharedData::gEvaluationTime*0.1;  // original CEC
	//_initialEnergy = 2*MedeaSpSharedData::gEvaluationTime;  // original CEC, adapte avec nv schema
	//_initialEnergy = MedeaSpSharedData::gEvaluationTime*0.1 / 2; // half the maximum lifetime.  // used to be: 2*MedeaSpSharedData::gEvaluationTime*0.1;
	//_initialEnergy = MedeaSpSharedData::gEvaluationTime*2; // MUST BE AT LEAST MedeaSpSharedData::gEvaluationTime otw a dead agent will never be revived  // / 2.0; // half the maximum lifetime + nv schema (entier)
	
	_wm->setEnergyLevel(MedeaSpSharedData::gEnergyInit);
	//_deltaEnergy = 10.0; // CEC
	_wm->setDeltaEnergy(0.0); // MedeaSp

	for(int i = 0 ; i<MedeaSpSharedData::gNbTypeResource;i++)
	{
		_wm->setAngleToClosestEnergyPoint(i,0);
		_wm->setDistanceToClosestEnergyPoint(i,0);
		_wm->setEnergyPointDirectionAngleValue(i,0);
		_wm->setEnergyPointDistanceValue(i,0);
		
	}
	gProperties.checkAndGetPropertyValue("nbHiddenNeurons",&_nbHiddenNeurons,true);
	
	_wm->setActiveStatus(true);

	if ( gVerbose )
	{
		std::cout << "robot #" << _wm->_agentId << " perceptron \n" ;	
	}
}

MedeaSpPerceptronControlArchitecture::~MedeaSpPerceptronControlArchitecture()
{
	// nothing to do.
}

void MedeaSpPerceptronControlArchitecture::reset()
{
	_parameters.clear();
	_parameters = _wm->_genome;
	
}


// perform one controller update
// set motor value using motor format.
void MedeaSpPerceptronControlArchitecture::step()
{
	_iteration++;

	if ( _wm->getNewGenomeStatus() ) // check for new NN parameters
	{
		reset();
		_wm->setNewGenomeStatus(false);
	}

/*	if ( _wm->_age < 0 ) // problem: _age is nowhere to be incremented
	{
		// ** security control (prior to a new behavior, get out of crash situation) -- random noise to avoid "STALL" status
		_wm->_desiredTranslationalValue = ( ranf()*2.-1. ) * gMaxTranslationalSpeed ;
		_wm->_desiredRotationalVelocity =( ranf()*2.-1. ) * gMaxRotationalSpeed ;
		currentObserver->setKey( ( ranf()*2.-1. ) * MedeaSpSharedData::gMaxKeyRange);
		return;
	}
*/
	_wm->_desiredTranslationalValue = 0.0;
	_wm->_desiredRotationalVelocity = 0.0;
	
	//We take the world observer which store now the energypoints vector! 
	/////////// NO MORE "gEnergyPoints"!!!!!!!
	
	MedeaSpWorldObserver * wo = dynamic_cast<MedeaSpWorldObserver * >(_wm->_world->getWorldObserver());

	std::vector< MedeaSpEnergyPoint*> * allEP=wo->getEnergyPoints();
	
	if ( _wm->getActiveStatus() == true && !MedeaSpSharedData::gExperimentNoMovements)
	{
		double angleToClosestEnergyPoint = 0.0;
		double shortestDistance = 0.0; //search the current active energy point
		Point2d posRobot(_wm->_xReal,_wm->_yReal);
		
		for(int i = 0; i<MedeaSpSharedData::gNbTypeResource ; i++)
		{
		    //Could be better : trying to generalise for n type of energy point
			std::vector<MedeaSpEnergyPoint*>::iterator closestPoint = allEP->begin();
			//Look for the first point of the good type
			while( (int)((*closestPoint)->getType()) != i ){
				closestPoint++;
			}
			
			shortestDistance = getEuclidianDistance (posRobot,(*closestPoint)->getPosition());
			
			for(std::vector<MedeaSpEnergyPoint*>::iterator it = allEP->begin(); it < allEP->end(); it++)//Can be optimised and starting with "closest point"would allow us not to check previous points again.j
			{
				if (((*it)->getType() == i))
				{
					double newDistance = getEuclidianDistance (posRobot,(*it)->getPosition());
					if(newDistance < shortestDistance)
					{
						shortestDistance = newDistance;
						closestPoint = it;
					}
				}
			}	
			//compute the orientation of the active sun ( in degree between 0 and 360 )
			//compute the orientation of the closest energy point ( in degree between 0 and 360 )
			angleToClosestEnergyPoint = (atan2((*closestPoint)->getPosition().y-posRobot.y,(*closestPoint)->getPosition().x-	posRobot.x)/M_PI)*180.0;
			angleToClosestEnergyPoint += 360.0 ;
			angleToClosestEnergyPoint = computeModulo(angleToClosestEnergyPoint,360.0);
			if ( angleToClosestEnergyPoint > 180 ) // force btw -180 and 180
				angleToClosestEnergyPoint -= 360.0;

			//compute the angle between the actual orientation of the robot and the orientation of the closest energy point ( in degree between -180 and 180 )
			double diffAngleToClosestEnergyPoint= angleToClosestEnergyPoint -  _wm->_agentAbsoluteOrientation ;
			if ( diffAngleToClosestEnergyPoint< -180.0 )
			{
				diffAngleToClosestEnergyPoint+= 360.0 ; 
			}
			if ( diffAngleToClosestEnergyPoint> 180.0 )
			{
				diffAngleToClosestEnergyPoint-= 360.0 ;
			}

			//cast the diffAngle between -1 and 1
			diffAngleToClosestEnergyPoint= diffAngleToClosestEnergyPoint/ 180.0 ; 
			_wm->setEnergyPointDirectionAngleValue(i,diffAngleToClosestEnergyPoint);
			
			//cast the shortest distance between 0 and 1
			if ( shortestDistance > gSensorRange )
				shortestDistance = 1.0;
			else
				shortestDistance = shortestDistance / (double)gSensorRange;
			_wm->setEnergyPointDistanceValue(i,shortestDistance);

	//		if ( gAgentIndexFocus == _wm->_agentId )
			if ( gVerbose && gInspectAgent && gAgentIndexFocus == _wm->_agentId )
			{
				std::cout << "SunSensorValue: " << _wm->getEnergyPointDirectionAngleValue(i) << " , " << _wm->getEnergyPointDistanceValue(i) << std::endl;			
			}
		}
		
		std::vector<double> hiddenLayer;
		hiddenLayer.resize(_nbHiddenNeurons);
		for (int j= 0 ; j < _nbHiddenNeurons ; j++ )
		{
			hiddenLayer[j] = 0.0;
		}

		int geneToUse = 0;

		// inputs to hidden Layer

		// distance sensors
		for ( int i = 0 ; i < _wm->_sensorCount ; i++ )
		{
			for (int j= 0 ; j < _nbHiddenNeurons ; j++ )
			{
				hiddenLayer[j] += (_wm->getSensorDistanceValue(i)/_wm->getSensorMaximumDistanceValue(i)) * _parameters[geneToUse] ;  // !N - corrected BUG di0319 - use normalized sensor value in 0...1
				geneToUse ++;
			}
		}

		//floor sensor
		for (int j= 0 ; j < _nbHiddenNeurons ; j++ )
		{
			if ( _wm->_floorSensor != 0 )		// binary detector -- either something, or nothing.
				hiddenLayer[j] += 1.0  * _parameters[geneToUse];
			//hiddenLayer[j] += _wm->_floorSensor/255.0  * _parameters[geneToUse];
			geneToUse ++;
		}
		
		//direction of the closest energy point of each type 		
// 		gLogFile << "nress,"<<MedeaSpSharedData::gNbTypeResource<<std::endl;
		
		for(int i=0 ; i < MedeaSpSharedData::gNbTypeResource ; i++)
		{
			for (int j= 0 ; j < _nbHiddenNeurons ; j++ )
			{
				hiddenLayer[j] += _wm->getEnergyPointDirectionAngleValue(i)  * _parameters[geneToUse];		// ??? !N - should be angle. naming problem, code correct.
				geneToUse ++;
			}
		}

		//direction of the closest energy point
		for(int i=0 ; i < MedeaSpSharedData::gNbTypeResource ; i++)
		{
// 		    std::cout<<"i:"<< i<<", energydistancevalue: "<<_wm->getEnergyPointDistanceValue(i)<<std::endl  ;
			for (int j= 0 ; j < _nbHiddenNeurons ; j++ )
			{
				hiddenLayer[j] += _wm->getEnergyPointDistanceValue(i)  * _parameters[geneToUse];		// ??? !N - should be angle. naming problem, code correct.
				geneToUse ++;
			}
		}
			
		//energy level
		for (int j= 0 ; j < _nbHiddenNeurons ; j++ )
		{
			hiddenLayer[j] +=  (_wm->getEnergyLevel()/MedeaSpSharedData::gEnergyMax)  * _parameters[geneToUse];  // !N : added: energy value normalization btw 0 and 1.
			geneToUse ++;
		}

		//bias
		for (int j= 0 ; j < _nbHiddenNeurons ; j++ )
		{
			hiddenLayer[j] += 1.0  * _parameters[geneToUse];
			geneToUse ++;
		}

		//activation function on hidden layer
// 		for (int j= 0 ; j < _nbHiddenNeurons ; j++ )
// 		{
// 			hiddenLayer[j] = tanh(hiddenLayer[j]);
// 		}
		
		//hiddenLayer to output
		_wm->_desiredTranslationalValue = 0;
		_wm->_desiredRotationalVelocity = 0;
		for (int j= 0 ; j < _nbHiddenNeurons ; j++ )
		{
			_wm->_desiredTranslationalValue += hiddenLayer[j] * _parameters[geneToUse] ;
			geneToUse ++;
		}
		for (int j= 0 ; j < _nbHiddenNeurons ; j++ )
		{
			_wm->_desiredRotationalVelocity += hiddenLayer[j] * _parameters[geneToUse] ;
			geneToUse ++;
		}
		
		_wm->_desiredTranslationalValue += 1.0 * _parameters[geneToUse] ;
		geneToUse ++;
// gLogFile<<geneToUse<<" ability "<<_parameters[87]<< " vs "<<_parameters[geneToUse] <<" vs "<<_wm->getAbilityToForage()<<" size"<<_wm->_genome.size()<< std::endl;
		_wm->_desiredRotationalVelocity += 1.0 * _parameters[geneToUse] ;
	

		//activation function on output
		_wm->_desiredTranslationalValue = tanh( _wm->_desiredTranslationalValue ) ;  // !N note that tanh is optional for ANN outputs.
		_wm->_desiredRotationalVelocity = tanh( _wm->_desiredRotationalVelocity );
	
		// normalize to motor interval values
		_wm->_desiredTranslationalValue = _wm->_desiredTranslationalValue * gMaxTranslationalSpeed;
		_wm->_desiredRotationalVelocity = _wm->_desiredRotationalVelocity * gMaxRotationalSpeed;
		

	}

}

