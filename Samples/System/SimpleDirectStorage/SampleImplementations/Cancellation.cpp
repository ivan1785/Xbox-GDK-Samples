//--------------------------------------------------------------------------------------
// Cancellation.cpp
//
// Advanced Technology Group (ATG)
// Copyright (C) Microsoft Corporation. All rights reserved.
//--------------------------------------------------------------------------------------

#include "pch.h"
#include "Cancellation.h"

#define VALIDATE_READS

bool Cancellation::RunSample(const std::wstring& fileName, uint64_t dataFileSize)
{
    // Shared code to initialize DirectStorage, open the data file, and create a queue
    // The queue size has enough space for all reads and a status slot for each batch
    SetupDirectStorage(fileName, c_totalReads + 1);

    // Helper code that creates a set of random reads and match destination buffers
    GenerateRandomReadLocationsAndDestinationBuffers(dataFileSize, c_totalReads);

    // Create a status array with one slot. For this sample there is only one notification needed after the last request
    DX::ThrowIfFailed(m_factory->CreateStatusArray(1, u8"Cancellation Status Array", __uuidof(IDStorageStatusArrayX), (void **)(m_status.ReleaseAndGetAddressOf())));

    // Setup a set of rotating masks that will be used to tag read requests
    // The read tag controls which requests are canceled
    // In this sample each bit represents a different read type and a specific read has three types associated with it
    uint64_t currentReadType[c_numSpeculativeFlags] = { SPECULATIVE_TEXTURE, SPECULATIVE_MESH, SPECULATIVE_TERRAIN };

    // array to save the requested cancellation tag used in the request for later validation of data
    std::unique_ptr<uint64_t[]> savedCancellationTags(new uint64_t[c_totalReads]);

    // enqueue all the reads with each read getting its own tag based on currentReadType
    uint32_t curBuffer = 0;
    for (uint32_t curRead = 0; curRead < c_totalReads; ++curRead, ++curBuffer)
    {
        DSTORAGE_REQUEST request = {};
        request.File = m_file.Get();
        request.Destination = m_destinationBuffers[curBuffer].get();
        request.DestinationSize = m_readSizes[curBuffer];
        request.FileOffset = m_readLocations[curBuffer];
        request.SourceSize = m_readSizes[curBuffer];

        // tag each read with bits set for which types are used by the request
        // rotate the read types used for each read to cover a wide range of types
        for (uint32_t i = 0; i < c_numSpeculativeFlags; i++)
        {
            currentReadType[i]++;
            currentReadType[i] %= NUM_READ_TYPES;
            request.CancellationTag += (1ULL << currentReadType[i]);
        }

        // save the cancellation tag associated with this read for later verification testing
        savedCancellationTags[curBuffer] = request.CancellationTag;

        // Enqueue the request into the relevant queue
        m_queue->EnqueueRequest(&request);
    }

    // enqueue the status array along with the slot in the array we want to be signaled when all previous enqueued reads have completed
    m_queue->EnqueueStatus(m_status.Get(), 0);

    // Submit the entire queue to the hardware
    m_queue->Submit();
    Sleep(1);				// wait for some requests to finish being processed

    // The rule for cancellation is: tag (from request) & mask (Param 1) == value (Param 2)
    // cancel all requests that belong to a specific type, in this case all terrain that is being speculatively loaded
    // a request might also be part of several types, several bits are set in the tag
    // Note: some requests will have already finished or are being processed by the hardware, these will still complete
    // Requests that are not being processed by the hardware will be canceled before being sent to the hardware
    m_queue->CancelRequestsWithTag(1ULL << SPECULATIVE_TERRAIN, 1ULL << SPECULATIVE_TERRAIN);

    while (!m_status->IsComplete(0))
    {
        Sleep(1);
    }

    // at this point the batch has completed
    // some reads may have been successfully canceled, some may have already hit the hardware and are unable to be canceled
    // It is not safe until this point to free all memory for the canceled requests

    // check the contents of the data read from the file to make sure the correct contents were loaded
    // skip the reads that canceled. Their data may or may not be valid depending on if the request was fully canceled
#ifdef VALIDATE_READS
    curBuffer = 0;
    for (uint32_t curRead = 0; curRead < c_totalReads; ++curRead, ++curBuffer)
    {
        if ((savedCancellationTags[curBuffer] & (1ULL << SPECULATIVE_TERRAIN)) == (1ULL << SPECULATIVE_TERRAIN))
            continue;

        uint32_t startValue = static_cast<uint32_t> (m_readLocations[curBuffer] / sizeof(uint32_t));
        uint32_t* temp = (uint32_t*)m_destinationBuffers[curBuffer].get();
        uint32_t numberEntries = m_readSizes[curBuffer] / sizeof(uint32_t);
        for (uint32_t location = 0; location < numberEntries; location++)
        {
            if (temp[location] != startValue)
                DebugBreak();
            assert(temp[location] == startValue);
            startValue++;
        }
    }
#endif

    // Cleanup all related objects created
    ShutdownDirectStorage();
    return true;
}