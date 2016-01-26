/*
 *  MedeaSpAgentWorldModel.cpp
 *  roborobo-online
 *
 *  Created by Nicolas on 15/04/10.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "mEDEA-sp/include/MedeaSpAgentWorldModel.h"
#include <mEDEA-sp/include/MedeaSpSharedData.h>

MedeaSpAgentWorldModel::MedeaSpAgentWorldModel()
{
	_dateOfBirth=0;
	_waitForGenome=false;
	_fatherId=-1;
	_maturity=0;
	_lifeTime = 1;
	_energyPointDirectionAngleValue = std::vector<double>(MedeaSpSharedData::gNbTypeResource,0);
	_distanceToClosestEnergyPoint=std::vector<double>(MedeaSpSharedData::gNbTypeResource,0); 
	_energyPointDistanceValue =std::vector<double>(MedeaSpSharedData::gNbTypeResource,0);
	_angleToClosestEnergyPoint = std::vector<double>(MedeaSpSharedData::gNbTypeResource,0);
	_energyCounter = std::vector<double>(MedeaSpSharedData::gNbTypeResource+1,0);
	_vectorFitnesses = std::vector<double>(0);

}

MedeaSpAgentWorldModel::~MedeaSpAgentWorldModel()
{
}

double MedeaSpAgentWorldModel::getEnergyPointDirectionAngleValue(int i)
{
	return _energyPointDirectionAngleValue[i];
}

double MedeaSpAgentWorldModel::getEnergyPointDistanceValue(int i)
{
	return _energyPointDistanceValue[i];
}

void MedeaSpAgentWorldModel::setEnergyPointDirectionAngleValue(int i, double __value )
{
	_energyPointDirectionAngleValue[i] = __value;
}

void MedeaSpAgentWorldModel::setEnergyPointDistanceValue(int i, double __value )
{
	_energyPointDistanceValue[i] = __value;
}

bool MedeaSpAgentWorldModel::getActiveStatus()
{
	return _isActive;
	//(!_waitForGenome) && (_waitingTime<=0) && (_lifeTime > 0);
}

void MedeaSpAgentWorldModel::setActiveStatus( bool __isActive )
{
	_isActive = __isActive;
}

double MedeaSpAgentWorldModel::getEnergyLevel()
{
	return _energyLevel;
}

void MedeaSpAgentWorldModel::setEnergyLevel(double inValue)
{
	_energyLevel = inValue;
}

void MedeaSpAgentWorldModel::setEnergyFound(double inValue)
{
	_energyFound = inValue;
}

double MedeaSpAgentWorldModel::getEnergyFound()
{
	return _energyFound;
}

double MedeaSpAgentWorldModel::getDeltaEnergy()
{
	return _deltaEnergy;
}

void MedeaSpAgentWorldModel::setDeltaEnergy(double inValue)
{
	_deltaEnergy = inValue;
}

void MedeaSpAgentWorldModel::setAngleToClosestEnergyPoint(int i, double __value )
{
	_angleToClosestEnergyPoint[i] = __value;
}

double MedeaSpAgentWorldModel::getAngleToClosestEnergyPoint(int i )
{
	return _angleToClosestEnergyPoint[i];
}

void MedeaSpAgentWorldModel::setDistanceToClosestEnergyPoint(int i,  double __value )
{
	_distanceToClosestEnergyPoint[i] = __value;
}

double MedeaSpAgentWorldModel::getDistanceToClosestEnergyPoint(int i)
{
	return _distanceToClosestEnergyPoint[i];
}


double MedeaSpAgentWorldModel::getAbilityToForage()
{
	// 	std::cout<<"abili: "<<_genome.back()<<" vs "<< _genome[77]<<std::endl;
	return _genome.back();
}


void MedeaSpAgentWorldModel::setFatherId(int fathId){
	_fatherId = fathId;

}

int MedeaSpAgentWorldModel::getFatherId(){
	return _fatherId ;

}

void MedeaSpAgentWorldModel::setMaturity(int fathId){
	_maturity = fathId;

}

double MedeaSpAgentWorldModel::getFitness(){
	return _fitness ;

}

void MedeaSpAgentWorldModel::setFitness(double fathId){
	_fitness = fathId;

}

int MedeaSpAgentWorldModel::getMaturity(){
	return _maturity ;

}

void MedeaSpAgentWorldModel::setDateOfBirth(int fathId){
	_dateOfBirth = fathId;

}

int MedeaSpAgentWorldModel::getDateOfBirth(){
	return _dateOfBirth ;

}



void MedeaSpAgentWorldModel::setLifeTime(int lifeTime)
{
	_lifeTime = lifeTime;
}

int MedeaSpAgentWorldModel::getLifeTime()
{
	return _lifeTime;   
}


int MedeaSpAgentWorldModel::vectorFitnessesSize(){
	return _vectorFitnesses.size();
}

void MedeaSpAgentWorldModel::vectorFitnessesPull(){
	_vectorFitnesses.erase(_vectorFitnesses.begin());
}

void MedeaSpAgentWorldModel::vectorFitnessesPush(double energy){ 
			_vectorFitnesses.push_back(energy);
}

double MedeaSpAgentWorldModel::vectorFitnessesGet(int i){ 
			return _vectorFitnesses[i];
}

/*************************
 * Energy counter manipulator
 */
void MedeaSpAgentWorldModel::setEnergyCounter(std::vector<double> __energyCounter)
{
	_energyCounter=__energyCounter;
}
void MedeaSpAgentWorldModel::setEnergyCounterOfOneRessource(int ressource,double value)
{
	// 	gLogFile<<"ressourcing"<<"r"<<ressource<<" "<<value<<std::endl;
	_energyCounter[ressource]=value;
}
double MedeaSpAgentWorldModel::getEnergyCounterOfOneRessource(int ressource)
{
	return _energyCounter[ressource];
}
std::vector<double>  MedeaSpAgentWorldModel::getEnergyCounter()
{
	return _energyCounter;
}
void MedeaSpAgentWorldModel::resetEnergyCounter()
{
	for(unsigned int i =0; i<_energyCounter.size();i++)
		_energyCounter[i]=0.0;
}
//***************


void MedeaSpAgentWorldModel::setWaitForGenome(bool wait)
{

	_waitForGenome = wait;
}

bool MedeaSpAgentWorldModel::getWaitForGenome()
{

	return _waitForGenome;
}

void MedeaSpAgentWorldModel::resetActiveGenome()
{
	int nbInput = _sensorCount + 1 + MedeaSpSharedData::gNbTypeResource *2 + 1 + 1 ; //sensors + floorSensor + energyDirection * gNbTypeResource +  energyDistance  * gNbTypeResource+ energyLevel + bias
	int nbOutput = 2 ; // rotation + velocity 
	int nbGene = ( nbInput * _nbHiddenNeurons ) + ( _nbHiddenNeurons * nbOutput) + nbOutput + 1; // from input to hidden layer + from hiddenLayer to output + from bias to output + forageAbility
	std::cout << std::flush ;
	_genome.clear();
	for ( int i = 0 ; i != nbGene ; i++ )
	{
		_genome.push_back(((rand()%800)/400.0)-1.0);
	}
	_currentGenome = _genome;
	setNewGenomeStatus(true);
	_genomesList.clear();
}


void MedeaSpAgentWorldModel::computeFitness(){

	vectorFitnessesPull();
	vectorFitnessesPush(getEnergyFound());
	double fitness = 0.0;
	for (unsigned int i = 0 ; i < _vectorFitnesses.size() ; i ++)
	{
		fitness += vectorFitnessesGet(i);
	}
	setFitness(fitness / (double) _vectorFitnesses.size());
}
