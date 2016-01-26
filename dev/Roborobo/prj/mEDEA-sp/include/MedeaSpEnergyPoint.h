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

    You should have received a copy of the GNU General Public Licng with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

#ifndef MEDEASPENERGYPOINT_H
#define MEDEASPENERGYPOINT_H

#include "RoboroboMain/common.h"
#include "Utilities/Misc.h"
#include "World/InanimateObject.h"
#include <World/EnergyPoint.h>

  
class MedeaSpEnergyPoint: public EnergyPoint
{
	protected :
		float _type;	//a float which give the "type" of the source. a float because we can imagine to evolve this, traiting it like the chemichal phenotype of a plant
		int _nHarvest;	//Number of robots which have taken energy from this energypoint
		int _Q_E;	//Quantity of energy available on the source for this iteration
		
	public :
		MedeaSpEnergyPoint(float __type);
		void setType(float __type);
		float getType();
		int getNHarvest();
		void setNHarverst(int nHarvest);
		void setQ_E(int);
		int getQ_E();
		void display();
};

#endif // MEDEASPENERGYPOINT_H
