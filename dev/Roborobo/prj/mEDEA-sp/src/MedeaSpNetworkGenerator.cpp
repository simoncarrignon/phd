/*
    Created by Simon on 11-09-16
    
    Copyright (C) 2011

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/
#include "mEDEA-sp/include/MedeaSpNetworkGenerator.h"

#include "World/World.h"
#include <math.h>

#include <algorithm>

MedeaSpNetworkGenerator::MedeaSpNetworkGenerator(int __sparsity)
{
	this->_sparsity=__sparsity;
        this->_graphFileName= "logs/graph_" + gStartTime + ".dot";

	this->nEdgeToConnectThemAll = gAgentCounter;
	this-> markThemAll = new std::vector<int>(gAgentCounter,-1);
	this->currentNbEdge = 0.0;
	this->allRemainingConnexions = new std::vector<pair>(); //Use to store all remaining connexions
	
	//initialisation of the radioNetworkArray and of the two other vectors previously built
	for ( int i = 0 ; i < gAgentCounter-1 ; i++ ){
		for ( int j = i+1 ; j < gAgentCounter ; j++ )
		{
			gRadioNetworkArray[i][j] = gRadioNetworkArray[j][i] = 0;
			allRemainingConnexions->push_back(pair(i,j));
		}
	}
}

MedeaSpNetworkGenerator::~MedeaSpNetworkGenerator()
{
	markThemAll->clear();
// 	markThemAll->erase();
	allRemainingConnexions->clear();
// 	allRemainingConnexions->erase();
	delete markThemAll;
	delete allRemainingConnexions;
	
}

std::string MedeaSpNetworkGenerator::getGraphFileName(){return this->_graphFileName;}

int MedeaSpNetworkGenerator::getSparsity(){ return this->_sparsity;}

void MedeaSpNetworkGenerator::buildChainBiasedNetwork()
{
	//WARNING : in this function the way the sparsity is compute is note good at all (here it's the mean DENSITY not the SPARSITY)
	
	std::vector<int> * densByNode = new std::vector<int>(gAgentCounter);//Vector storing the density for each node
	
	//initialisation of the radioNetworkArray and of the two other vector previously built
	for ( int i = 0 ; i < gAgentCounter-1 ; i++ ){
		for ( int j = i+1 ; j < gAgentCounter ; j++ )
		{
			densByNode->at(j)=densByNode->at(i)=0;
			gRadioNetworkArray[i][j] = gRadioNetworkArray[j][i] = 0;
		}
	}
	
	gRadioNetworkArray[0][gAgentCounter-1] = gRadioNetworkArray[gAgentCounter-1][0] = 1;//add the link between the last and the first node
	densByNode->at(0)++;
	densByNode->at(gAgentCounter-1)++;
	for ( int i = 0 ; i < gAgentCounter-1 ; i++ ){
		gRadioNetworkArray[i][i+1] = gRadioNetworkArray[i+1][i] = 1; // current implementation: either signal or no signal.
		densByNode->at(i)++;
		densByNode->at(i+1)++;
	}
	
	int meanSparsity=0;
	for(unsigned int i=0; i<densByNode->size();i++)
		meanSparsity+=densByNode->at(i);
	meanSparsity=meanSparsity/densByNode->size();

	
	std::cout<<"means"<<meanSparsity<<std::endl;

	while(meanSparsity < this->_sparsity && allRemainingConnexions->size()>0){
		meanSparsity=0;
		int newLink = rand()%allRemainingConnexions->size();
		int nodeA=allRemainingConnexions->at(newLink).first;
		int nodeB=allRemainingConnexions->at(newLink).second;
		gRadioNetworkArray[nodeA][nodeB]=gRadioNetworkArray[nodeB][nodeA]=1;
		densByNode->at(nodeA)++;
		densByNode->at(nodeB)++;
		allRemainingConnexions->erase(allRemainingConnexions->begin()+newLink);
		
		for(unsigned int i=0; i<densByNode->size();i++)
			meanSparsity+=densByNode->at(i);
		meanSparsity=meanSparsity/densByNode->size();

		std::cout<<"means"<<meanSparsity<<std::endl;
	}
	
}


void MedeaSpNetworkGenerator::writeGraphFile()

{
	std::ofstream graphFile;
 	graphFile.open(this->_graphFileName.c_str());

	graphFile<<"graph sparsity{"<<std::endl;
	graphFile<<"overlap=scale;"<<std::endl;
	for ( int i = 0 ; i < gAgentCounter-1 ; i++ )
		for ( int j = i+1 ; j < gAgentCounter ; j++ )
		{
			if(gRadioNetworkArray[i][j] == 1)
				graphFile<<""<<i<<"--"<<j<<";"<<std::endl;
		}
	graphFile<<"}"<<std::endl;
	graphFile.close();
}



void MedeaSpNetworkGenerator::buildRandomNetwork(){
	
	
	float sparsity = this->_sparsity/1000.0;
	bool notAbleToReachSparsity=false;
	while(nEdgeToSparsity(currentNbEdge) > sparsity && !notAbleToReachSparsity ){
		
		pair theNewEdge;
		
		nEdgeToConnectThemAll=updateNbEdgeToConnectThemAll();
		
		//std::cerr<<"currenSpars:"<<nEdgeToSparsity(currentNbEdge)<<" needed: "<<sparsity<<std::endl;
		if(nEdgeToSparsity(currentNbEdge+nEdgeToConnectThemAll)<= sparsity  ){
			int oldNEdgeToConnect=nEdgeToConnectThemAll;
			theNewEdge= connectTwoSubGraph();
			addNewEdge(theNewEdge);
			markThemAll=new std::vector<int>(gAgentCounter,-1);
			nEdgeToConnectThemAll=updateNbEdgeToConnectThemAll();
			while(oldNEdgeToConnect<=nEdgeToConnectThemAll){
				removeEdge(theNewEdge);
				allRemainingConnexions->push_back(theNewEdge);
				theNewEdge=connectTwoSubGraph();
				addNewEdge(theNewEdge);
				markThemAll=new std::vector<int>(gAgentCounter,-1);
				nEdgeToConnectThemAll=updateNbEdgeToConnectThemAll();
				
				
			}
			currentNbEdge++;
		}
		else
		{
			theNewEdge = pickNewEdge();
			addNewEdge(theNewEdge);
			markThemAll=new std::vector<int>(gAgentCounter,-1);
			nEdgeToConnectThemAll=updateNbEdgeToConnectThemAll();
			currentNbEdge++;
		}

	}//one edge to connect them all, and in the network, bind them.
}

float MedeaSpNetworkGenerator::nEdgeToSparsity(int nEdge){

	return 1-(nEdge)*2.0/(float)(gAgentCounter*(gAgentCounter-1));
	
}


int MedeaSpNetworkGenerator::updateNbEdgeToConnectThemAll(){
	int mark=0;
	for(int i=0; i<gAgentCounter;i++){
		//if the node is node already marked, mark it
		if(markThemAll->at(i)==-1){
			mark=*std::max_element(markThemAll->begin(),markThemAll->end())+1;
			markThemAll->at(i)=mark;
		}//else use the mark already given
		else
			mark=markThemAll->at(i);
		
		//expend the mark to all connected nodes
		for(int j=i+1;j<gAgentCounter;j++){
			if(gRadioNetworkArray[i][j]==1 ||gRadioNetworkArray[j][i] ==1 )
				markThemAll->at(j)=mark;
			
		}
	}
	return  (*std::max_element(markThemAll->begin(),markThemAll->end()));
}


pair MedeaSpNetworkGenerator::connectTwoSubGraph(){
	pair StanSmith;
	int newPairIndex;
	do{
		newPairIndex = rand() %  allRemainingConnexions->size();
		StanSmith=allRemainingConnexions->at(newPairIndex);
	}while(markThemAll->at(StanSmith.first) == markThemAll->at(StanSmith.second));
	//while we don't find a pair made by two node from two different subgraph ie that are note marked with the same int, search another pair
	
	//when find, suppres the pair from the lsit of remainings pairs
	allRemainingConnexions->erase(allRemainingConnexions->begin()+newPairIndex);

	return StanSmith;
		
}

pair MedeaSpNetworkGenerator::pickNewEdge(){

	int newPairIndex = rand() % allRemainingConnexions->size();
	pair StanSmith=allRemainingConnexions->at(newPairIndex);
	allRemainingConnexions->erase(allRemainingConnexions->begin()+newPairIndex);
	
	return StanSmith;
	
	
}

void MedeaSpNetworkGenerator::addNewEdge(pair theNewEdge)
{
	gRadioNetworkArray[theNewEdge.first][theNewEdge.second]=1;
	gRadioNetworkArray[theNewEdge.second][theNewEdge.first]=1;
}

void MedeaSpNetworkGenerator::removeEdge(pair theEdgeToRemove)
{
	gRadioNetworkArray[theEdgeToRemove.first][theEdgeToRemove.second]=0;
	gRadioNetworkArray[theEdgeToRemove.second][theEdgeToRemove.first]=0;
}
