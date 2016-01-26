/*
    <one line to give the program's name and a brief idea of what it does.>
    Copyright (C) <year>  <name of author>

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

#ifndef MEDEASPNETWORKGENERATOR_H
#define MEDEASPNETWORKGENERATOR_H

#include "RoboroboMain/common.h"
#include "Utilities/Misc.h"
#include "World/InanimateObject.h"
#include "World/EnergyPoint.h"


typedef std::pair<int,int> pair;//a link beetwen two nodes

class MedeaSpNetworkGenerator
{

private:
	int _sparsity; //the sparsity*100 of the network
	std::string _graphFileName;
	int nEdgeToConnectThemAll; 
	std::vector< pair >* allRemainingConnexions;
	double currentNbEdge;
	std::vector<int> * markThemAll;
public :
	
	
	MedeaSpNetworkGenerator(int sparsity);
	~MedeaSpNetworkGenerator();

	
	int getSparsity();
	
	std::string getGraphFileName();
	
	//Build a network where robots are randomly linked together, with a constraint that the network is connexe. This method is biased because all network start with a chain which link all robots two by two 
	void buildChainBiasedNetwork();

	//Write a file which can be used with the graphViz utilities to plot the network
	void writeGraphFile();
	
	void buildRandomNetwork();//build a connexe random network in gRadioNetworkArray
	
	int updateNbEdgeToConnectThemAll();//Update the number of remaining edges needed to make the network connexe
	
	void addNewEdge(pair newPair); //add a new edge into the radioNetworkArray
	void removeEdge(pair theEdgeToRemove);//suppress a new edge into the radioNetworkArray
	pair pickNewEdge();//return an edge randomly selected from the allRemainingConnexions and suppres this edge frome allRemainingConnexions.
	
	//Given a number of edge( 0<..<nMaxEdge), return a degree of sparsity(0<..<1)
	float nEdgeToSparsity(int nEdge);
	
	pair connectTwoSubGraph();//Return a pair wich connect two subgraph together and suppress the founded pair from this->allRemainingConnexions
    
	
 

};

#endif // MEDEASPNETWORKGENERATOR_H
