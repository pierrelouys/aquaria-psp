/*
Copyright (C) 2007, 2010 - Bit-Blot

This file is part of Aquaria.

Aquaria is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/
#include "Core.h"

#ifdef RLT_FIXED
	#define BASE_ARRAY_SIZE 100  // Size of an object array in a new layer
#endif

RenderObjectLayer::RenderObjectLayer()
#ifdef RLT_FIXED
	: renderObjects(BASE_ARRAY_SIZE)
#endif
{	
	followCamera = NO_FOLLOW_CAMERA;
	visible = true;
	startPass = endPass = 0;
	followCameraLock = FCL_NONE;
	cull = true;
	update = true;

	mode = Core::MODE_2D;

	color = Vector(1,1,1);
	
#ifdef RLT_FIXED
	const int size = renderObjects.size();
	for (int i = 0; i < size; i++)
		renderObjects[i] = 0;
	objectCount = 0;
	firstFreeIdx = 0;
#endif
}

void RenderObjectLayer::setCull(bool v)
{
	this->cull = v;
}

#ifdef RLT_DYNAMIC
bool sortRenderObjectsByDepth(RenderObject *r1, RenderObject *r2)
{
	return r1->getSortDepth() < r2->getSortDepth();
}
#endif

void RenderObjectLayer::sort()
{
#ifdef RLT_FIXED
	// Compress the list before sorting to boost speed.
	const int size = renderObjects.size();
	int from, to;
	for (to = 0; to < size; to++) {
		if (!renderObjects[to])
			break;
	}
	for (from = to+1; from < size; from++) {
		if (renderObjects[from])
		{
			renderObjects[to] = renderObjects[from];
			renderObjects[to]->setIdx(to);
			to++;
		}
	}
	if (to != objectCount)
	{
		std::ostringstream os;
		os << "Objects lost in sort! (" << to << " != " << objectCount << ")";
		errorLog(os.str());
		objectCount = to;
	}
	const int count = objectCount;

	// Save a copy of all objects' depths so we don't have to call
	// getSortDepth() in a greater-order loop.
	std::vector<float> sortDepths(count);
	for (int i = 0; i < count; i++)
	{
		sortDepths[i] = renderObjects[i]->getSortDepth();
	}

	// FIXME: Just a simple selection sort for now.  Is this fast enough?
	// Might need to use quicksort instead.
	for (int i = 0; i < count-1; i++)
	{
		int best = i;
		float bestDepth = sortDepths[i];
		for (int j = i+1; j < count; j++)
		{
			if (sortDepths[j] < bestDepth)
			{
				best = j;
				bestDepth = sortDepths[j];
			}
		}
		if (best != i)
		{
			RenderObject *r = renderObjects[i];
			renderObjects[i] = renderObjects[best];
			renderObjects[i]->setIdx(i);
			renderObjects[best] = r;
			renderObjects[best]->setIdx(best);
			float d = sortDepths[i];
			sortDepths[i] = sortDepths[best];
			sortDepths[best] = d;
		}
	}
#endif
#ifdef RLT_DYNAMIC
	renderObjectList.sort(sortRenderObjectsByDepth);
#endif
}

void RenderObjectLayer::add(RenderObject* r)
{
#ifdef RLT_FIXED
	int size = renderObjects.size();
	if (firstFreeIdx >= size)
	{
		size += size/2;  // Increase size by 50% each time we fill up.
		renderObjects.resize(size);
	}

	renderObjects[firstFreeIdx] = r;
	objectCount++;
	r->setIdx(firstFreeIdx);

	for (; firstFreeIdx < size; firstFreeIdx++)
	{
		if (!renderObjects[firstFreeIdx])
			break;
	}
#endif
#ifdef RLT_DYNAMIC
	renderObjectList.push_back(r);
#endif
#ifdef RLT_MAP
	renderObjectMap[intptr_t(r)] = r;
#endif
}

void RenderObjectLayer::remove(RenderObject* r)
{
#ifdef RLT_FIXED
	const int idx = r->getIdx();
	if (idx < 0 || idx >= renderObjects.size())
	{
		errorLog("Trying to remove RenderObject with invalid index");
		return;
	}
	if (renderObjects[idx] != r)
	{
		errorLog("RenderObject pointer doesn't match array");
		return;
	}
	renderObjects[idx] = 0;
	objectCount--;
	if (idx < firstFreeIdx)
		firstFreeIdx = idx;
	r->setIdx(-1);
#endif
#ifdef RLT_DYNAMIC
	renderObjectList.remove(r);
#endif
#ifdef RLT_MAP
	renderObjectMap[intptr_t(r)] = 0;
#endif
}

void RenderObjectLayer::moveToFront(RenderObject *r)
{
#ifdef RLT_FIXED
	const int size = renderObjects.size();
	const int curIdx = r->getIdx();
	int lastUsed;
	for (lastUsed = size-1; lastUsed > curIdx; lastUsed--)
	{
		if (renderObjects[lastUsed])
			break;
	}

	if (curIdx == lastUsed)
	{
		// Already at the front, so nothing to do.
	}
	else if (lastUsed < size-1)
	{
		const int newIdx = lastUsed + 1;
		renderObjects[curIdx] = 0;
		renderObjects[newIdx] = r;
		r->setIdx(newIdx);
		if (firstFreeIdx == newIdx)
			firstFreeIdx++;
	}
	else if (objectCount == size)
	{
		// Expand the array so future calls have a bit of breathing room.
		const int newSize = size + 10;
		renderObjects.resize(newSize);
		renderObjects[curIdx] = 0;
		renderObjects[size] = r;
		r->setIdx(size);
		for (int i = size+1; i < newSize; i++)
			renderObjects[i] = 0;
		firstFreeIdx = size+1;
	}
	else
	{
		// Need to shift elements downward to make room for the new one.
		renderObjects[curIdx] = 0;
		int lastFree;
		for (lastFree = lastUsed-1; lastFree > curIdx; lastFree--)
		{
			if (!renderObjects[lastFree])
				break;
		}

		for (int i = lastFree + 1; i <= lastUsed; i++)
		{
			renderObjects[i-1] = renderObjects[i];
			renderObjects[i-1]->setIdx(i-1);
		}

		renderObjects[lastUsed] = r;
		r->setIdx(lastUsed);
		if (firstFreeIdx == lastFree)
			firstFreeIdx = lastUsed + 1;
	}
#endif  // RLT_FIXED
#ifdef RLT_DYNAMIC
	renderObjectList.remove(r);
	renderObjectList.push_back(r);
#endif
}

void RenderObjectLayer::moveToBack(RenderObject *r)
{
#ifdef RLT_FIXED
	const int size = renderObjects.size();
	const int curIdx = r->getIdx();
	int firstUsed;
	for (firstUsed = 0; firstUsed < curIdx; firstUsed++)
	{
		if (renderObjects[firstUsed])
			break;
	}

	if (curIdx == firstUsed)
	{
		// Already at the back, so nothing to do.
	}
	else if (firstUsed > 0)
	{
		const int newIdx = firstUsed - 1;
		renderObjects[curIdx] = 0;
		renderObjects[newIdx] = r;
		r->setIdx(newIdx);
		if (firstFreeIdx == newIdx)
			firstFreeIdx++;
	}
	else if (objectCount == size)
	{
		const int newSize = size + 10;
		const int sizeDiff = newSize - size;
		const int newIdx = sizeDiff - 1;

		renderObjects.resize(newSize);
		renderObjects[curIdx] = 0;
		for (int i = newSize - 1; i >= sizeDiff; i--)
		{
			renderObjects[i] = renderObjects[i - sizeDiff];
			renderObjects[i]->setIdx(i);
		}
		for (int i = 0; i < newIdx; i++)
			renderObjects[i] = 0;
		renderObjects[newIdx] = r;
		r->setIdx(newIdx);
		firstFreeIdx = 0;
	}
	else
	{
		renderObjects[curIdx] = 0;
		if (curIdx < firstFreeIdx)
			firstFreeIdx = curIdx;
		for (int i = firstFreeIdx; i > 0; i--)
		{
			renderObjects[i] = renderObjects[i-1];
			renderObjects[i]->setIdx(i);
		}
		renderObjects[0] = r;
		r->setIdx(0);
		for (firstFreeIdx++; firstFreeIdx < size; firstFreeIdx++)
		{
			if (!renderObjects[firstFreeIdx])
				break;
		}
	}
#endif  // RLT_FIXED
#ifdef RLT_DYNAMIC
        renderObjectList.remove(r);
	renderObjectList.push_front(r);
#endif
}

void RenderObjectLayer::renderPass(int pass)
{
	core->currentLayerPass = pass;

	for (RenderObject *robj = getFirst(); robj; robj = getNext())
	{
		core->totalRenderObjectCount++;
		if (robj->getParent() || robj->alpha.x == 0)
			continue;

		if (!this->cull || !robj->cull || robj->isOnScreen())
		{
			robj->render();
			core->renderObjectCount++;
		}
		core->processedRenderObjectCount++;
	}
}
