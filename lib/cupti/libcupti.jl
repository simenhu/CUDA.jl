using CEnum

const uint64_t = UInt64
const uint32_t = UInt32

# outlined functionality to avoid GC frame allocation
@noinline function throw_api_error(res)
    if res == CUPTI_ERROR_OUT_OF_MEMORY
        throw(OutOfGPUMemoryError())
    else
        throw(CUPTIError(res))
    end
end

macro check(ex, errs...)
    check = :(isequal(err, CUPTI_ERROR_OUT_OF_MEMORY))
    for err in errs
        check = :($check || isequal(err, $(esc(err))))
    end

    quote
        res = @retry_reclaim err -> $check $(esc(ex))
        if res != CUPTI_SUCCESS
            throw_api_error(res)
        end

        nothing
    end
end

@cenum CUptiResult::UInt32 begin
    CUPTI_SUCCESS = 0
    CUPTI_ERROR_INVALID_PARAMETER = 1
    CUPTI_ERROR_INVALID_DEVICE = 2
    CUPTI_ERROR_INVALID_CONTEXT = 3
    CUPTI_ERROR_INVALID_EVENT_DOMAIN_ID = 4
    CUPTI_ERROR_INVALID_EVENT_ID = 5
    CUPTI_ERROR_INVALID_EVENT_NAME = 6
    CUPTI_ERROR_INVALID_OPERATION = 7
    CUPTI_ERROR_OUT_OF_MEMORY = 8
    CUPTI_ERROR_HARDWARE = 9
    CUPTI_ERROR_PARAMETER_SIZE_NOT_SUFFICIENT = 10
    CUPTI_ERROR_API_NOT_IMPLEMENTED = 11
    CUPTI_ERROR_MAX_LIMIT_REACHED = 12
    CUPTI_ERROR_NOT_READY = 13
    CUPTI_ERROR_NOT_COMPATIBLE = 14
    CUPTI_ERROR_NOT_INITIALIZED = 15
    CUPTI_ERROR_INVALID_METRIC_ID = 16
    CUPTI_ERROR_INVALID_METRIC_NAME = 17
    CUPTI_ERROR_QUEUE_EMPTY = 18
    CUPTI_ERROR_INVALID_HANDLE = 19
    CUPTI_ERROR_INVALID_STREAM = 20
    CUPTI_ERROR_INVALID_KIND = 21
    CUPTI_ERROR_INVALID_EVENT_VALUE = 22
    CUPTI_ERROR_DISABLED = 23
    CUPTI_ERROR_INVALID_MODULE = 24
    CUPTI_ERROR_INVALID_METRIC_VALUE = 25
    CUPTI_ERROR_HARDWARE_BUSY = 26
    CUPTI_ERROR_NOT_SUPPORTED = 27
    CUPTI_ERROR_UM_PROFILING_NOT_SUPPORTED = 28
    CUPTI_ERROR_UM_PROFILING_NOT_SUPPORTED_ON_DEVICE = 29
    CUPTI_ERROR_UM_PROFILING_NOT_SUPPORTED_ON_NON_P2P_DEVICES = 30
    CUPTI_ERROR_UM_PROFILING_NOT_SUPPORTED_WITH_MPS = 31
    CUPTI_ERROR_CDP_TRACING_NOT_SUPPORTED = 32
    CUPTI_ERROR_VIRTUALIZED_DEVICE_NOT_SUPPORTED = 33
    CUPTI_ERROR_CUDA_COMPILER_NOT_COMPATIBLE = 34
    CUPTI_ERROR_INSUFFICIENT_PRIVILEGES = 35
    CUPTI_ERROR_OLD_PROFILER_API_INITIALIZED = 36
    CUPTI_ERROR_OPENACC_UNDEFINED_ROUTINE = 37
    CUPTI_ERROR_LEGACY_PROFILER_NOT_SUPPORTED = 38
    CUPTI_ERROR_MULTIPLE_SUBSCRIBERS_NOT_SUPPORTED = 39
    CUPTI_ERROR_VIRTUALIZED_DEVICE_INSUFFICIENT_PRIVILEGES = 40
    CUPTI_ERROR_CONFIDENTIAL_COMPUTING_NOT_SUPPORTED = 41
    CUPTI_ERROR_CMP_DEVICE_NOT_SUPPORTED = 42
    CUPTI_ERROR_UNKNOWN = 999
    CUPTI_ERROR_FORCE_INT = 2147483647
end

@checked function cuptiGetResultString(result, str)
    @ccall libcupti.cuptiGetResultString(result::CUptiResult,
                                         str::Ptr{Cstring})::CUptiResult
end

@checked function cuptiGetVersion(version)
    @ccall libcupti.cuptiGetVersion(version::Ptr{UInt32})::CUptiResult
end

@cenum CUpti_ApiCallbackSite::UInt32 begin
    CUPTI_API_ENTER = 0
    CUPTI_API_EXIT = 1
    CUPTI_API_CBSITE_FORCE_INT = 2147483647
end

@cenum CUpti_CallbackDomain::UInt32 begin
    CUPTI_CB_DOMAIN_INVALID = 0
    CUPTI_CB_DOMAIN_DRIVER_API = 1
    CUPTI_CB_DOMAIN_RUNTIME_API = 2
    CUPTI_CB_DOMAIN_RESOURCE = 3
    CUPTI_CB_DOMAIN_SYNCHRONIZE = 4
    CUPTI_CB_DOMAIN_NVTX = 5
    CUPTI_CB_DOMAIN_SIZE = 6
    CUPTI_CB_DOMAIN_FORCE_INT = 2147483647
end

@cenum CUpti_CallbackIdResource::UInt32 begin
    CUPTI_CBID_RESOURCE_INVALID = 0
    CUPTI_CBID_RESOURCE_CONTEXT_CREATED = 1
    CUPTI_CBID_RESOURCE_CONTEXT_DESTROY_STARTING = 2
    CUPTI_CBID_RESOURCE_STREAM_CREATED = 3
    CUPTI_CBID_RESOURCE_STREAM_DESTROY_STARTING = 4
    CUPTI_CBID_RESOURCE_CU_INIT_FINISHED = 5
    CUPTI_CBID_RESOURCE_MODULE_LOADED = 6
    CUPTI_CBID_RESOURCE_MODULE_UNLOAD_STARTING = 7
    CUPTI_CBID_RESOURCE_MODULE_PROFILED = 8
    CUPTI_CBID_RESOURCE_GRAPH_CREATED = 9
    CUPTI_CBID_RESOURCE_GRAPH_DESTROY_STARTING = 10
    CUPTI_CBID_RESOURCE_GRAPH_CLONED = 11
    CUPTI_CBID_RESOURCE_GRAPHNODE_CREATE_STARTING = 12
    CUPTI_CBID_RESOURCE_GRAPHNODE_CREATED = 13
    CUPTI_CBID_RESOURCE_GRAPHNODE_DESTROY_STARTING = 14
    CUPTI_CBID_RESOURCE_GRAPHNODE_DEPENDENCY_CREATED = 15
    CUPTI_CBID_RESOURCE_GRAPHNODE_DEPENDENCY_DESTROY_STARTING = 16
    CUPTI_CBID_RESOURCE_GRAPHEXEC_CREATE_STARTING = 17
    CUPTI_CBID_RESOURCE_GRAPHEXEC_CREATED = 18
    CUPTI_CBID_RESOURCE_GRAPHEXEC_DESTROY_STARTING = 19
    CUPTI_CBID_RESOURCE_GRAPHNODE_CLONED = 20
    CUPTI_CBID_RESOURCE_SIZE = 21
    CUPTI_CBID_RESOURCE_FORCE_INT = 2147483647
end

@cenum CUpti_CallbackIdSync::UInt32 begin
    CUPTI_CBID_SYNCHRONIZE_INVALID = 0
    CUPTI_CBID_SYNCHRONIZE_STREAM_SYNCHRONIZED = 1
    CUPTI_CBID_SYNCHRONIZE_CONTEXT_SYNCHRONIZED = 2
    CUPTI_CBID_SYNCHRONIZE_SIZE = 3
    CUPTI_CBID_SYNCHRONIZE_FORCE_INT = 2147483647
end

struct CUpti_CallbackData
    callbackSite::CUpti_ApiCallbackSite
    functionName::Cstring
    functionParams::Ptr{Cvoid}
    functionReturnValue::Ptr{Cvoid}
    symbolName::Cstring
    context::CUcontext
    contextUid::UInt32
    correlationData::Ptr{UInt64}
    correlationId::UInt32
end

struct var"##Ctag#737"
    data::NTuple{8,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#737"}, f::Symbol)
    f === :stream && return Ptr{CUstream}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#737", f::Symbol)
    r = Ref{var"##Ctag#737"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#737"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#737"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct CUpti_ResourceData
    data::NTuple{24,UInt8}
end

function Base.getproperty(x::Ptr{CUpti_ResourceData}, f::Symbol)
    f === :context && return Ptr{CUcontext}(x + 0)
    f === :resourceHandle && return Ptr{var"##Ctag#737"}(x + 8)
    f === :resourceDescriptor && return Ptr{Ptr{Cvoid}}(x + 16)
    return getfield(x, f)
end

function Base.getproperty(x::CUpti_ResourceData, f::Symbol)
    r = Ref{CUpti_ResourceData}(x)
    ptr = Base.unsafe_convert(Ptr{CUpti_ResourceData}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{CUpti_ResourceData}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct CUpti_ModuleResourceData
    moduleId::UInt32
    cubinSize::Csize_t
    pCubin::Cstring
end

struct CUpti_GraphData
    graph::CUgraph
    originalGraph::CUgraph
    node::CUgraphNode
    originalNode::CUgraphNode
    nodeType::CUgraphNodeType
    dependency::CUgraphNode
    graphExec::CUgraphExec
end

struct CUpti_SynchronizeData
    context::CUcontext
    stream::CUstream
end

struct CUpti_NvtxData
    functionName::Cstring
    functionParams::Ptr{Cvoid}
    functionReturnValue::Ptr{Cvoid}
end

const CUpti_CallbackId = UInt32

# typedef void ( CUPTIAPI * CUpti_CallbackFunc ) ( void * userdata , CUpti_CallbackDomain domain , CUpti_CallbackId cbid , const void * cbdata )
const CUpti_CallbackFunc = Ptr{Cvoid}

mutable struct CUpti_Subscriber_st end

const CUpti_SubscriberHandle = Ptr{CUpti_Subscriber_st}

const CUpti_DomainTable = Ptr{CUpti_CallbackDomain}

@checked function cuptiSupportedDomains(domainCount, domainTable)
    initialize_context()
    @ccall libcupti.cuptiSupportedDomains(domainCount::Ptr{Csize_t},
                                          domainTable::Ptr{CUpti_DomainTable})::CUptiResult
end

@checked function cuptiSubscribe(subscriber, callback, userdata)
    initialize_context()
    @ccall libcupti.cuptiSubscribe(subscriber::Ptr{CUpti_SubscriberHandle},
                                   callback::CUpti_CallbackFunc,
                                   userdata::Ptr{Cvoid})::CUptiResult
end

@checked function cuptiUnsubscribe(subscriber)
    initialize_context()
    @ccall libcupti.cuptiUnsubscribe(subscriber::CUpti_SubscriberHandle)::CUptiResult
end

@checked function cuptiGetCallbackState(enable, subscriber, domain, cbid)
    initialize_context()
    @ccall libcupti.cuptiGetCallbackState(enable::Ptr{UInt32},
                                          subscriber::CUpti_SubscriberHandle,
                                          domain::CUpti_CallbackDomain,
                                          cbid::CUpti_CallbackId)::CUptiResult
end

@checked function cuptiEnableCallback(enable, subscriber, domain, cbid)
    initialize_context()
    @ccall libcupti.cuptiEnableCallback(enable::UInt32, subscriber::CUpti_SubscriberHandle,
                                        domain::CUpti_CallbackDomain,
                                        cbid::CUpti_CallbackId)::CUptiResult
end

@checked function cuptiEnableDomain(enable, subscriber, domain)
    initialize_context()
    @ccall libcupti.cuptiEnableDomain(enable::UInt32, subscriber::CUpti_SubscriberHandle,
                                      domain::CUpti_CallbackDomain)::CUptiResult
end

@checked function cuptiEnableAllDomains(enable, subscriber)
    initialize_context()
    @ccall libcupti.cuptiEnableAllDomains(enable::UInt32,
                                          subscriber::CUpti_SubscriberHandle)::CUptiResult
end

@checked function cuptiGetCallbackName(domain, cbid, name)
    initialize_context()
    @ccall libcupti.cuptiGetCallbackName(domain::CUpti_CallbackDomain, cbid::UInt32,
                                         name::Ptr{Cstring})::CUptiResult
end

const CUpti_EventID = UInt32

const CUpti_EventDomainID = UInt32

const CUpti_EventGroup = Ptr{Cvoid}

@cenum CUpti_DeviceAttributeDeviceClass::UInt32 begin
    CUPTI_DEVICE_ATTR_DEVICE_CLASS_TESLA = 0
    CUPTI_DEVICE_ATTR_DEVICE_CLASS_QUADRO = 1
    CUPTI_DEVICE_ATTR_DEVICE_CLASS_GEFORCE = 2
    CUPTI_DEVICE_ATTR_DEVICE_CLASS_TEGRA = 3
end

@cenum CUpti_DeviceAttribute::UInt32 begin
    CUPTI_DEVICE_ATTR_MAX_EVENT_ID = 1
    CUPTI_DEVICE_ATTR_MAX_EVENT_DOMAIN_ID = 2
    CUPTI_DEVICE_ATTR_GLOBAL_MEMORY_BANDWIDTH = 3
    CUPTI_DEVICE_ATTR_INSTRUCTION_PER_CYCLE = 4
    CUPTI_DEVICE_ATTR_INSTRUCTION_THROUGHPUT_SINGLE_PRECISION = 5
    CUPTI_DEVICE_ATTR_MAX_FRAME_BUFFERS = 6
    CUPTI_DEVICE_ATTR_PCIE_LINK_RATE = 7
    CUPTI_DEVICE_ATTR_PCIE_LINK_WIDTH = 8
    CUPTI_DEVICE_ATTR_PCIE_GEN = 9
    CUPTI_DEVICE_ATTR_DEVICE_CLASS = 10
    CUPTI_DEVICE_ATTR_FLOP_SP_PER_CYCLE = 11
    CUPTI_DEVICE_ATTR_FLOP_DP_PER_CYCLE = 12
    CUPTI_DEVICE_ATTR_MAX_L2_UNITS = 13
    CUPTI_DEVICE_ATTR_MAX_SHARED_MEMORY_CACHE_CONFIG_PREFER_SHARED = 14
    CUPTI_DEVICE_ATTR_MAX_SHARED_MEMORY_CACHE_CONFIG_PREFER_L1 = 15
    CUPTI_DEVICE_ATTR_MAX_SHARED_MEMORY_CACHE_CONFIG_PREFER_EQUAL = 16
    CUPTI_DEVICE_ATTR_FLOP_HP_PER_CYCLE = 17
    CUPTI_DEVICE_ATTR_NVLINK_PRESENT = 18
    CUPTI_DEVICE_ATTR_GPU_CPU_NVLINK_BW = 19
    CUPTI_DEVICE_ATTR_NVSWITCH_PRESENT = 20
    CUPTI_DEVICE_ATTR_FORCE_INT = 2147483647
end

@cenum CUpti_EventDomainAttribute::UInt32 begin
    CUPTI_EVENT_DOMAIN_ATTR_NAME = 0
    CUPTI_EVENT_DOMAIN_ATTR_INSTANCE_COUNT = 1
    CUPTI_EVENT_DOMAIN_ATTR_TOTAL_INSTANCE_COUNT = 3
    CUPTI_EVENT_DOMAIN_ATTR_COLLECTION_METHOD = 4
    CUPTI_EVENT_DOMAIN_ATTR_FORCE_INT = 2147483647
end

@cenum CUpti_EventCollectionMethod::UInt32 begin
    CUPTI_EVENT_COLLECTION_METHOD_PM = 0
    CUPTI_EVENT_COLLECTION_METHOD_SM = 1
    CUPTI_EVENT_COLLECTION_METHOD_INSTRUMENTED = 2
    CUPTI_EVENT_COLLECTION_METHOD_NVLINK_TC = 3
    CUPTI_EVENT_COLLECTION_METHOD_FORCE_INT = 2147483647
end

@cenum CUpti_EventGroupAttribute::UInt32 begin
    CUPTI_EVENT_GROUP_ATTR_EVENT_DOMAIN_ID = 0
    CUPTI_EVENT_GROUP_ATTR_PROFILE_ALL_DOMAIN_INSTANCES = 1
    CUPTI_EVENT_GROUP_ATTR_USER_DATA = 2
    CUPTI_EVENT_GROUP_ATTR_NUM_EVENTS = 3
    CUPTI_EVENT_GROUP_ATTR_EVENTS = 4
    CUPTI_EVENT_GROUP_ATTR_INSTANCE_COUNT = 5
    CUPTI_EVENT_GROUP_ATTR_PROFILING_SCOPE = 6
    CUPTI_EVENT_GROUP_ATTR_FORCE_INT = 2147483647
end

@cenum CUpti_EventProfilingScope::UInt32 begin
    CUPTI_EVENT_PROFILING_SCOPE_CONTEXT = 0
    CUPTI_EVENT_PROFILING_SCOPE_DEVICE = 1
    CUPTI_EVENT_PROFILING_SCOPE_BOTH = 2
    CUPTI_EVENT_PROFILING_SCOPE_FORCE_INT = 2147483647
end

@cenum CUpti_EventAttribute::UInt32 begin
    CUPTI_EVENT_ATTR_NAME = 0
    CUPTI_EVENT_ATTR_SHORT_DESCRIPTION = 1
    CUPTI_EVENT_ATTR_LONG_DESCRIPTION = 2
    CUPTI_EVENT_ATTR_CATEGORY = 3
    CUPTI_EVENT_ATTR_PROFILING_SCOPE = 5
    CUPTI_EVENT_ATTR_FORCE_INT = 2147483647
end

@cenum CUpti_EventCollectionMode::UInt32 begin
    CUPTI_EVENT_COLLECTION_MODE_CONTINUOUS = 0
    CUPTI_EVENT_COLLECTION_MODE_KERNEL = 1
    CUPTI_EVENT_COLLECTION_MODE_FORCE_INT = 2147483647
end

@cenum CUpti_EventCategory::UInt32 begin
    CUPTI_EVENT_CATEGORY_INSTRUCTION = 0
    CUPTI_EVENT_CATEGORY_MEMORY = 1
    CUPTI_EVENT_CATEGORY_CACHE = 2
    CUPTI_EVENT_CATEGORY_PROFILE_TRIGGER = 3
    CUPTI_EVENT_CATEGORY_SYSTEM = 4
    CUPTI_EVENT_CATEGORY_FORCE_INT = 2147483647
end

@cenum CUpti_ReadEventFlags::UInt32 begin
    CUPTI_EVENT_READ_FLAG_NONE = 0
    CUPTI_EVENT_READ_FLAG_FORCE_INT = 2147483647
end

struct CUpti_EventGroupSet
    numEventGroups::UInt32
    eventGroups::Ptr{CUpti_EventGroup}
end

struct CUpti_EventGroupSets
    numSets::UInt32
    sets::Ptr{CUpti_EventGroupSet}
end

@checked function cuptiSetEventCollectionMode(context, mode)
    initialize_context()
    @ccall libcupti.cuptiSetEventCollectionMode(context::CUcontext,
                                                mode::CUpti_EventCollectionMode)::CUptiResult
end

@checked function cuptiDeviceGetAttribute(device, attrib, valueSize, value)
    initialize_context()
    @ccall libcupti.cuptiDeviceGetAttribute(device::CUdevice, attrib::CUpti_DeviceAttribute,
                                            valueSize::Ptr{Csize_t},
                                            value::Ptr{Cvoid})::CUptiResult
end

@checked function cuptiDeviceGetTimestamp(context, timestamp)
    initialize_context()
    @ccall libcupti.cuptiDeviceGetTimestamp(context::CUcontext,
                                            timestamp::Ptr{UInt64})::CUptiResult
end

@checked function cuptiDeviceGetNumEventDomains(device, numDomains)
    initialize_context()
    @ccall libcupti.cuptiDeviceGetNumEventDomains(device::CUdevice,
                                                  numDomains::Ptr{UInt32})::CUptiResult
end

@checked function cuptiDeviceEnumEventDomains(device, arraySizeBytes, domainArray)
    initialize_context()
    @ccall libcupti.cuptiDeviceEnumEventDomains(device::CUdevice,
                                                arraySizeBytes::Ptr{Csize_t},
                                                domainArray::Ptr{CUpti_EventDomainID})::CUptiResult
end

@checked function cuptiDeviceGetEventDomainAttribute(device, eventDomain, attrib, valueSize,
                                                     value)
    initialize_context()
    @ccall libcupti.cuptiDeviceGetEventDomainAttribute(device::CUdevice,
                                                       eventDomain::CUpti_EventDomainID,
                                                       attrib::CUpti_EventDomainAttribute,
                                                       valueSize::Ptr{Csize_t},
                                                       value::Ptr{Cvoid})::CUptiResult
end

@checked function cuptiGetNumEventDomains(numDomains)
    initialize_context()
    @ccall libcupti.cuptiGetNumEventDomains(numDomains::Ptr{UInt32})::CUptiResult
end

@checked function cuptiEnumEventDomains(arraySizeBytes, domainArray)
    initialize_context()
    @ccall libcupti.cuptiEnumEventDomains(arraySizeBytes::Ptr{Csize_t},
                                          domainArray::Ptr{CUpti_EventDomainID})::CUptiResult
end

@checked function cuptiEventDomainGetAttribute(eventDomain, attrib, valueSize, value)
    initialize_context()
    @ccall libcupti.cuptiEventDomainGetAttribute(eventDomain::CUpti_EventDomainID,
                                                 attrib::CUpti_EventDomainAttribute,
                                                 valueSize::Ptr{Csize_t},
                                                 value::Ptr{Cvoid})::CUptiResult
end

@checked function cuptiEventDomainGetNumEvents(eventDomain, numEvents)
    initialize_context()
    @ccall libcupti.cuptiEventDomainGetNumEvents(eventDomain::CUpti_EventDomainID,
                                                 numEvents::Ptr{UInt32})::CUptiResult
end

@checked function cuptiEventDomainEnumEvents(eventDomain, arraySizeBytes, eventArray)
    initialize_context()
    @ccall libcupti.cuptiEventDomainEnumEvents(eventDomain::CUpti_EventDomainID,
                                               arraySizeBytes::Ptr{Csize_t},
                                               eventArray::Ptr{CUpti_EventID})::CUptiResult
end

@checked function cuptiEventGetAttribute(event, attrib, valueSize, value)
    initialize_context()
    @ccall libcupti.cuptiEventGetAttribute(event::CUpti_EventID,
                                           attrib::CUpti_EventAttribute,
                                           valueSize::Ptr{Csize_t},
                                           value::Ptr{Cvoid})::CUptiResult
end

@checked function cuptiEventGetIdFromName(device, eventName, event)
    initialize_context()
    @ccall libcupti.cuptiEventGetIdFromName(device::CUdevice, eventName::Cstring,
                                            event::Ptr{CUpti_EventID})::CUptiResult
end

@checked function cuptiEventGroupCreate(context, eventGroup, flags)
    initialize_context()
    @ccall libcupti.cuptiEventGroupCreate(context::CUcontext,
                                          eventGroup::Ptr{CUpti_EventGroup},
                                          flags::UInt32)::CUptiResult
end

@checked function cuptiEventGroupDestroy(eventGroup)
    initialize_context()
    @ccall libcupti.cuptiEventGroupDestroy(eventGroup::CUpti_EventGroup)::CUptiResult
end

@checked function cuptiEventGroupGetAttribute(eventGroup, attrib, valueSize, value)
    initialize_context()
    @ccall libcupti.cuptiEventGroupGetAttribute(eventGroup::CUpti_EventGroup,
                                                attrib::CUpti_EventGroupAttribute,
                                                valueSize::Ptr{Csize_t},
                                                value::Ptr{Cvoid})::CUptiResult
end

@checked function cuptiEventGroupSetAttribute(eventGroup, attrib, valueSize, value)
    initialize_context()
    @ccall libcupti.cuptiEventGroupSetAttribute(eventGroup::CUpti_EventGroup,
                                                attrib::CUpti_EventGroupAttribute,
                                                valueSize::Csize_t,
                                                value::Ptr{Cvoid})::CUptiResult
end

@checked function cuptiEventGroupAddEvent(eventGroup, event)
    initialize_context()
    @ccall libcupti.cuptiEventGroupAddEvent(eventGroup::CUpti_EventGroup,
                                            event::CUpti_EventID)::CUptiResult
end

@checked function cuptiEventGroupRemoveEvent(eventGroup, event)
    initialize_context()
    @ccall libcupti.cuptiEventGroupRemoveEvent(eventGroup::CUpti_EventGroup,
                                               event::CUpti_EventID)::CUptiResult
end

@checked function cuptiEventGroupRemoveAllEvents(eventGroup)
    initialize_context()
    @ccall libcupti.cuptiEventGroupRemoveAllEvents(eventGroup::CUpti_EventGroup)::CUptiResult
end

@checked function cuptiEventGroupResetAllEvents(eventGroup)
    initialize_context()
    @ccall libcupti.cuptiEventGroupResetAllEvents(eventGroup::CUpti_EventGroup)::CUptiResult
end

@checked function cuptiEventGroupEnable(eventGroup)
    initialize_context()
    @ccall libcupti.cuptiEventGroupEnable(eventGroup::CUpti_EventGroup)::CUptiResult
end

@checked function cuptiEventGroupDisable(eventGroup)
    initialize_context()
    @ccall libcupti.cuptiEventGroupDisable(eventGroup::CUpti_EventGroup)::CUptiResult
end

@checked function cuptiEventGroupReadEvent(eventGroup, flags, event,
                                           eventValueBufferSizeBytes, eventValueBuffer)
    initialize_context()
    @ccall libcupti.cuptiEventGroupReadEvent(eventGroup::CUpti_EventGroup,
                                             flags::CUpti_ReadEventFlags,
                                             event::CUpti_EventID,
                                             eventValueBufferSizeBytes::Ptr{Csize_t},
                                             eventValueBuffer::Ptr{UInt64})::CUptiResult
end

@checked function cuptiEventGroupReadAllEvents(eventGroup, flags, eventValueBufferSizeBytes,
                                               eventValueBuffer, eventIdArraySizeBytes,
                                               eventIdArray, numEventIdsRead)
    initialize_context()
    @ccall libcupti.cuptiEventGroupReadAllEvents(eventGroup::CUpti_EventGroup,
                                                 flags::CUpti_ReadEventFlags,
                                                 eventValueBufferSizeBytes::Ptr{Csize_t},
                                                 eventValueBuffer::Ptr{UInt64},
                                                 eventIdArraySizeBytes::Ptr{Csize_t},
                                                 eventIdArray::Ptr{CUpti_EventID},
                                                 numEventIdsRead::Ptr{Csize_t})::CUptiResult
end

@checked function cuptiEventGroupSetsCreate(context, eventIdArraySizeBytes, eventIdArray,
                                            eventGroupPasses)
    initialize_context()
    @ccall libcupti.cuptiEventGroupSetsCreate(context::CUcontext,
                                              eventIdArraySizeBytes::Csize_t,
                                              eventIdArray::Ptr{CUpti_EventID},
                                              eventGroupPasses::Ptr{Ptr{CUpti_EventGroupSets}})::CUptiResult
end

@checked function cuptiEventGroupSetsDestroy(eventGroupSets)
    initialize_context()
    @ccall libcupti.cuptiEventGroupSetsDestroy(eventGroupSets::Ptr{CUpti_EventGroupSets})::CUptiResult
end

@checked function cuptiEventGroupSetEnable(eventGroupSet)
    initialize_context()
    @ccall libcupti.cuptiEventGroupSetEnable(eventGroupSet::Ptr{CUpti_EventGroupSet})::CUptiResult
end

@checked function cuptiEventGroupSetDisable(eventGroupSet)
    initialize_context()
    @ccall libcupti.cuptiEventGroupSetDisable(eventGroupSet::Ptr{CUpti_EventGroupSet})::CUptiResult
end

@checked function cuptiEnableKernelReplayMode(context)
    initialize_context()
    @ccall libcupti.cuptiEnableKernelReplayMode(context::CUcontext)::CUptiResult
end

@checked function cuptiDisableKernelReplayMode(context)
    initialize_context()
    @ccall libcupti.cuptiDisableKernelReplayMode(context::CUcontext)::CUptiResult
end

# typedef void ( CUPTIAPI * CUpti_KernelReplayUpdateFunc ) ( const char * kernelName , int numReplaysDone , void * customData )
const CUpti_KernelReplayUpdateFunc = Ptr{Cvoid}

@checked function cuptiKernelReplaySubscribeUpdate(updateFunc, customData)
    initialize_context()
    @ccall libcupti.cuptiKernelReplaySubscribeUpdate(updateFunc::CUpti_KernelReplayUpdateFunc,
                                                     customData::Ptr{Cvoid})::CUptiResult
end

const CUpti_MetricID = UInt32

@cenum CUpti_MetricCategory::UInt32 begin
    CUPTI_METRIC_CATEGORY_MEMORY = 0
    CUPTI_METRIC_CATEGORY_INSTRUCTION = 1
    CUPTI_METRIC_CATEGORY_MULTIPROCESSOR = 2
    CUPTI_METRIC_CATEGORY_CACHE = 3
    CUPTI_METRIC_CATEGORY_TEXTURE = 4
    CUPTI_METRIC_CATEGORY_NVLINK = 5
    CUPTI_METRIC_CATEGORY_PCIE = 6
    CUPTI_METRIC_CATEGORY_FORCE_INT = 2147483647
end

@cenum CUpti_MetricEvaluationMode::UInt32 begin
    CUPTI_METRIC_EVALUATION_MODE_PER_INSTANCE = 1
    CUPTI_METRIC_EVALUATION_MODE_AGGREGATE = 2
    CUPTI_METRIC_EVALUATION_MODE_FORCE_INT = 2147483647
end

@cenum CUpti_MetricValueKind::UInt32 begin
    CUPTI_METRIC_VALUE_KIND_DOUBLE = 0
    CUPTI_METRIC_VALUE_KIND_UINT64 = 1
    CUPTI_METRIC_VALUE_KIND_PERCENT = 2
    CUPTI_METRIC_VALUE_KIND_THROUGHPUT = 3
    CUPTI_METRIC_VALUE_KIND_INT64 = 4
    CUPTI_METRIC_VALUE_KIND_UTILIZATION_LEVEL = 5
    CUPTI_METRIC_VALUE_KIND_FORCE_INT = 2147483647
end

@cenum CUpti_MetricValueUtilizationLevel::UInt32 begin
    CUPTI_METRIC_VALUE_UTILIZATION_IDLE = 0
    CUPTI_METRIC_VALUE_UTILIZATION_LOW = 2
    CUPTI_METRIC_VALUE_UTILIZATION_MID = 5
    CUPTI_METRIC_VALUE_UTILIZATION_HIGH = 8
    CUPTI_METRIC_VALUE_UTILIZATION_MAX = 10
    CUPTI_METRIC_VALUE_UTILIZATION_FORCE_INT = 2147483647
end

@cenum CUpti_MetricAttribute::UInt32 begin
    CUPTI_METRIC_ATTR_NAME = 0
    CUPTI_METRIC_ATTR_SHORT_DESCRIPTION = 1
    CUPTI_METRIC_ATTR_LONG_DESCRIPTION = 2
    CUPTI_METRIC_ATTR_CATEGORY = 3
    CUPTI_METRIC_ATTR_VALUE_KIND = 4
    CUPTI_METRIC_ATTR_EVALUATION_MODE = 5
    CUPTI_METRIC_ATTR_FORCE_INT = 2147483647
end

struct CUpti_MetricValue
    data::NTuple{8,UInt8}
end

function Base.getproperty(x::Ptr{CUpti_MetricValue}, f::Symbol)
    f === :metricValueDouble && return Ptr{Cdouble}(x + 0)
    f === :metricValueUint64 && return Ptr{UInt64}(x + 0)
    f === :metricValueInt64 && return Ptr{Int64}(x + 0)
    f === :metricValuePercent && return Ptr{Cdouble}(x + 0)
    f === :metricValueThroughput && return Ptr{UInt64}(x + 0)
    f === :metricValueUtilizationLevel &&
        return Ptr{CUpti_MetricValueUtilizationLevel}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::CUpti_MetricValue, f::Symbol)
    r = Ref{CUpti_MetricValue}(x)
    ptr = Base.unsafe_convert(Ptr{CUpti_MetricValue}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{CUpti_MetricValue}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

@cenum CUpti_MetricPropertyDeviceClass::UInt32 begin
    CUPTI_METRIC_PROPERTY_DEVICE_CLASS_TESLA = 0
    CUPTI_METRIC_PROPERTY_DEVICE_CLASS_QUADRO = 1
    CUPTI_METRIC_PROPERTY_DEVICE_CLASS_GEFORCE = 2
    CUPTI_METRIC_PROPERTY_DEVICE_CLASS_TEGRA = 3
end

@cenum CUpti_MetricPropertyID::UInt32 begin
    CUPTI_METRIC_PROPERTY_MULTIPROCESSOR_COUNT = 0
    CUPTI_METRIC_PROPERTY_WARPS_PER_MULTIPROCESSOR = 1
    CUPTI_METRIC_PROPERTY_KERNEL_GPU_TIME = 2
    CUPTI_METRIC_PROPERTY_CLOCK_RATE = 3
    CUPTI_METRIC_PROPERTY_FRAME_BUFFER_COUNT = 4
    CUPTI_METRIC_PROPERTY_GLOBAL_MEMORY_BANDWIDTH = 5
    CUPTI_METRIC_PROPERTY_PCIE_LINK_RATE = 6
    CUPTI_METRIC_PROPERTY_PCIE_LINK_WIDTH = 7
    CUPTI_METRIC_PROPERTY_PCIE_GEN = 8
    CUPTI_METRIC_PROPERTY_DEVICE_CLASS = 9
    CUPTI_METRIC_PROPERTY_FLOP_SP_PER_CYCLE = 10
    CUPTI_METRIC_PROPERTY_FLOP_DP_PER_CYCLE = 11
    CUPTI_METRIC_PROPERTY_L2_UNITS = 12
    CUPTI_METRIC_PROPERTY_ECC_ENABLED = 13
    CUPTI_METRIC_PROPERTY_FLOP_HP_PER_CYCLE = 14
    CUPTI_METRIC_PROPERTY_GPU_CPU_NVLINK_BANDWIDTH = 15
end

@checked function cuptiGetNumMetrics(numMetrics)
    initialize_context()
    @ccall libcupti.cuptiGetNumMetrics(numMetrics::Ptr{UInt32})::CUptiResult
end

@checked function cuptiEnumMetrics(arraySizeBytes, metricArray)
    initialize_context()
    @ccall libcupti.cuptiEnumMetrics(arraySizeBytes::Ptr{Csize_t},
                                     metricArray::Ptr{CUpti_MetricID})::CUptiResult
end

@checked function cuptiDeviceGetNumMetrics(device, numMetrics)
    initialize_context()
    @ccall libcupti.cuptiDeviceGetNumMetrics(device::CUdevice,
                                             numMetrics::Ptr{UInt32})::CUptiResult
end

@checked function cuptiDeviceEnumMetrics(device, arraySizeBytes, metricArray)
    initialize_context()
    @ccall libcupti.cuptiDeviceEnumMetrics(device::CUdevice, arraySizeBytes::Ptr{Csize_t},
                                           metricArray::Ptr{CUpti_MetricID})::CUptiResult
end

@checked function cuptiMetricGetAttribute(metric, attrib, valueSize, value)
    initialize_context()
    @ccall libcupti.cuptiMetricGetAttribute(metric::CUpti_MetricID,
                                            attrib::CUpti_MetricAttribute,
                                            valueSize::Ptr{Csize_t},
                                            value::Ptr{Cvoid})::CUptiResult
end

@checked function cuptiMetricGetIdFromName(device, metricName, metric)
    initialize_context()
    @ccall libcupti.cuptiMetricGetIdFromName(device::CUdevice, metricName::Cstring,
                                             metric::Ptr{CUpti_MetricID})::CUptiResult
end

@checked function cuptiMetricGetNumEvents(metric, numEvents)
    initialize_context()
    @ccall libcupti.cuptiMetricGetNumEvents(metric::CUpti_MetricID,
                                            numEvents::Ptr{UInt32})::CUptiResult
end

@checked function cuptiMetricEnumEvents(metric, eventIdArraySizeBytes, eventIdArray)
    initialize_context()
    @ccall libcupti.cuptiMetricEnumEvents(metric::CUpti_MetricID,
                                          eventIdArraySizeBytes::Ptr{Csize_t},
                                          eventIdArray::Ptr{CUpti_EventID})::CUptiResult
end

@checked function cuptiMetricGetNumProperties(metric, numProp)
    initialize_context()
    @ccall libcupti.cuptiMetricGetNumProperties(metric::CUpti_MetricID,
                                                numProp::Ptr{UInt32})::CUptiResult
end

@checked function cuptiMetricEnumProperties(metric, propIdArraySizeBytes, propIdArray)
    initialize_context()
    @ccall libcupti.cuptiMetricEnumProperties(metric::CUpti_MetricID,
                                              propIdArraySizeBytes::Ptr{Csize_t},
                                              propIdArray::Ptr{CUpti_MetricPropertyID})::CUptiResult
end

@checked function cuptiMetricGetRequiredEventGroupSets(context, metric, eventGroupSets)
    initialize_context()
    @ccall libcupti.cuptiMetricGetRequiredEventGroupSets(context::CUcontext,
                                                         metric::CUpti_MetricID,
                                                         eventGroupSets::Ptr{Ptr{CUpti_EventGroupSets}})::CUptiResult
end

@checked function cuptiMetricCreateEventGroupSets(context, metricIdArraySizeBytes,
                                                  metricIdArray, eventGroupPasses)
    initialize_context()
    @ccall libcupti.cuptiMetricCreateEventGroupSets(context::CUcontext,
                                                    metricIdArraySizeBytes::Csize_t,
                                                    metricIdArray::Ptr{CUpti_MetricID},
                                                    eventGroupPasses::Ptr{Ptr{CUpti_EventGroupSets}})::CUptiResult
end

@checked function cuptiMetricGetValue(device, metric, eventIdArraySizeBytes, eventIdArray,
                                      eventValueArraySizeBytes, eventValueArray,
                                      timeDuration, metricValue)
    initialize_context()
    @ccall libcupti.cuptiMetricGetValue(device::CUdevice, metric::CUpti_MetricID,
                                        eventIdArraySizeBytes::Csize_t,
                                        eventIdArray::Ptr{CUpti_EventID},
                                        eventValueArraySizeBytes::Csize_t,
                                        eventValueArray::Ptr{UInt64}, timeDuration::UInt64,
                                        metricValue::Ptr{CUpti_MetricValue})::CUptiResult
end

@checked function cuptiMetricGetValue2(metric, eventIdArraySizeBytes, eventIdArray,
                                       eventValueArraySizeBytes, eventValueArray,
                                       propIdArraySizeBytes, propIdArray,
                                       propValueArraySizeBytes, propValueArray, metricValue)
    initialize_context()
    @ccall libcupti.cuptiMetricGetValue2(metric::CUpti_MetricID,
                                         eventIdArraySizeBytes::Csize_t,
                                         eventIdArray::Ptr{CUpti_EventID},
                                         eventValueArraySizeBytes::Csize_t,
                                         eventValueArray::Ptr{UInt64},
                                         propIdArraySizeBytes::Csize_t,
                                         propIdArray::Ptr{CUpti_MetricPropertyID},
                                         propValueArraySizeBytes::Csize_t,
                                         propValueArray::Ptr{UInt64},
                                         metricValue::Ptr{CUpti_MetricValue})::CUptiResult
end

@cenum CUpti_ActivityKind::UInt32 begin
    CUPTI_ACTIVITY_KIND_INVALID = 0
    CUPTI_ACTIVITY_KIND_MEMCPY = 1
    CUPTI_ACTIVITY_KIND_MEMSET = 2
    CUPTI_ACTIVITY_KIND_KERNEL = 3
    CUPTI_ACTIVITY_KIND_DRIVER = 4
    CUPTI_ACTIVITY_KIND_RUNTIME = 5
    CUPTI_ACTIVITY_KIND_EVENT = 6
    CUPTI_ACTIVITY_KIND_METRIC = 7
    CUPTI_ACTIVITY_KIND_DEVICE = 8
    CUPTI_ACTIVITY_KIND_CONTEXT = 9
    CUPTI_ACTIVITY_KIND_CONCURRENT_KERNEL = 10
    CUPTI_ACTIVITY_KIND_NAME = 11
    CUPTI_ACTIVITY_KIND_MARKER = 12
    CUPTI_ACTIVITY_KIND_MARKER_DATA = 13
    CUPTI_ACTIVITY_KIND_SOURCE_LOCATOR = 14
    CUPTI_ACTIVITY_KIND_GLOBAL_ACCESS = 15
    CUPTI_ACTIVITY_KIND_BRANCH = 16
    CUPTI_ACTIVITY_KIND_OVERHEAD = 17
    CUPTI_ACTIVITY_KIND_CDP_KERNEL = 18
    CUPTI_ACTIVITY_KIND_PREEMPTION = 19
    CUPTI_ACTIVITY_KIND_ENVIRONMENT = 20
    CUPTI_ACTIVITY_KIND_EVENT_INSTANCE = 21
    CUPTI_ACTIVITY_KIND_MEMCPY2 = 22
    CUPTI_ACTIVITY_KIND_METRIC_INSTANCE = 23
    CUPTI_ACTIVITY_KIND_INSTRUCTION_EXECUTION = 24
    CUPTI_ACTIVITY_KIND_UNIFIED_MEMORY_COUNTER = 25
    CUPTI_ACTIVITY_KIND_FUNCTION = 26
    CUPTI_ACTIVITY_KIND_MODULE = 27
    CUPTI_ACTIVITY_KIND_DEVICE_ATTRIBUTE = 28
    CUPTI_ACTIVITY_KIND_SHARED_ACCESS = 29
    CUPTI_ACTIVITY_KIND_PC_SAMPLING = 30
    CUPTI_ACTIVITY_KIND_PC_SAMPLING_RECORD_INFO = 31
    CUPTI_ACTIVITY_KIND_INSTRUCTION_CORRELATION = 32
    CUPTI_ACTIVITY_KIND_OPENACC_DATA = 33
    CUPTI_ACTIVITY_KIND_OPENACC_LAUNCH = 34
    CUPTI_ACTIVITY_KIND_OPENACC_OTHER = 35
    CUPTI_ACTIVITY_KIND_CUDA_EVENT = 36
    CUPTI_ACTIVITY_KIND_STREAM = 37
    CUPTI_ACTIVITY_KIND_SYNCHRONIZATION = 38
    CUPTI_ACTIVITY_KIND_EXTERNAL_CORRELATION = 39
    CUPTI_ACTIVITY_KIND_NVLINK = 40
    CUPTI_ACTIVITY_KIND_INSTANTANEOUS_EVENT = 41
    CUPTI_ACTIVITY_KIND_INSTANTANEOUS_EVENT_INSTANCE = 42
    CUPTI_ACTIVITY_KIND_INSTANTANEOUS_METRIC = 43
    CUPTI_ACTIVITY_KIND_INSTANTANEOUS_METRIC_INSTANCE = 44
    CUPTI_ACTIVITY_KIND_MEMORY = 45
    CUPTI_ACTIVITY_KIND_PCIE = 46
    CUPTI_ACTIVITY_KIND_OPENMP = 47
    CUPTI_ACTIVITY_KIND_INTERNAL_LAUNCH_API = 48
    CUPTI_ACTIVITY_KIND_MEMORY2 = 49
    CUPTI_ACTIVITY_KIND_MEMORY_POOL = 50
    CUPTI_ACTIVITY_KIND_GRAPH_TRACE = 51
    CUPTI_ACTIVITY_KIND_JIT = 52
    CUPTI_ACTIVITY_KIND_COUNT = 53
    CUPTI_ACTIVITY_KIND_FORCE_INT = 2147483647
end

@cenum CUpti_ActivityObjectKind::UInt32 begin
    CUPTI_ACTIVITY_OBJECT_UNKNOWN = 0
    CUPTI_ACTIVITY_OBJECT_PROCESS = 1
    CUPTI_ACTIVITY_OBJECT_THREAD = 2
    CUPTI_ACTIVITY_OBJECT_DEVICE = 3
    CUPTI_ACTIVITY_OBJECT_CONTEXT = 4
    CUPTI_ACTIVITY_OBJECT_STREAM = 5
    CUPTI_ACTIVITY_OBJECT_FORCE_INT = 2147483647
end

struct CUpti_ActivityObjectKindId
    data::NTuple{12,UInt8}
end

function Base.getproperty(x::Ptr{CUpti_ActivityObjectKindId}, f::Symbol)
    f === :pt && return Ptr{var"##Ctag#705"}(x + 0)
    f === :dcs && return Ptr{var"##Ctag#706"}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::CUpti_ActivityObjectKindId, f::Symbol)
    r = Ref{CUpti_ActivityObjectKindId}(x)
    ptr = Base.unsafe_convert(Ptr{CUpti_ActivityObjectKindId}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{CUpti_ActivityObjectKindId}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

@cenum CUpti_ActivityOverheadKind::UInt32 begin
    CUPTI_ACTIVITY_OVERHEAD_UNKNOWN = 0
    CUPTI_ACTIVITY_OVERHEAD_DRIVER_COMPILER = 1
    CUPTI_ACTIVITY_OVERHEAD_CUPTI_BUFFER_FLUSH = 65536
    CUPTI_ACTIVITY_OVERHEAD_CUPTI_INSTRUMENTATION = 131072
    CUPTI_ACTIVITY_OVERHEAD_CUPTI_RESOURCE = 196608
    CUPTI_ACTIVITY_OVERHEAD_FORCE_INT = 2147483647
end

@cenum CUpti_ActivityComputeApiKind::UInt32 begin
    CUPTI_ACTIVITY_COMPUTE_API_UNKNOWN = 0
    CUPTI_ACTIVITY_COMPUTE_API_CUDA = 1
    CUPTI_ACTIVITY_COMPUTE_API_CUDA_MPS = 2
    CUPTI_ACTIVITY_COMPUTE_API_FORCE_INT = 2147483647
end

@cenum CUpti_ActivityFlag::UInt32 begin
    CUPTI_ACTIVITY_FLAG_NONE = 0
    CUPTI_ACTIVITY_FLAG_DEVICE_CONCURRENT_KERNELS = 1
    CUPTI_ACTIVITY_FLAG_DEVICE_ATTRIBUTE_CUDEVICE = 1
    CUPTI_ACTIVITY_FLAG_MEMCPY_ASYNC = 1
    CUPTI_ACTIVITY_FLAG_MARKER_INSTANTANEOUS = 1
    CUPTI_ACTIVITY_FLAG_MARKER_START = 2
    CUPTI_ACTIVITY_FLAG_MARKER_END = 4
    CUPTI_ACTIVITY_FLAG_MARKER_SYNC_ACQUIRE = 8
    CUPTI_ACTIVITY_FLAG_MARKER_SYNC_ACQUIRE_SUCCESS = 16
    CUPTI_ACTIVITY_FLAG_MARKER_SYNC_ACQUIRE_FAILED = 32
    CUPTI_ACTIVITY_FLAG_MARKER_SYNC_RELEASE = 64
    CUPTI_ACTIVITY_FLAG_MARKER_COLOR_NONE = 1
    CUPTI_ACTIVITY_FLAG_MARKER_COLOR_ARGB = 2
    CUPTI_ACTIVITY_FLAG_GLOBAL_ACCESS_KIND_SIZE_MASK = 255
    CUPTI_ACTIVITY_FLAG_GLOBAL_ACCESS_KIND_LOAD = 256
    CUPTI_ACTIVITY_FLAG_GLOBAL_ACCESS_KIND_CACHED = 512
    CUPTI_ACTIVITY_FLAG_METRIC_OVERFLOWED = 1
    CUPTI_ACTIVITY_FLAG_METRIC_VALUE_INVALID = 2
    CUPTI_ACTIVITY_FLAG_INSTRUCTION_VALUE_INVALID = 1
    CUPTI_ACTIVITY_FLAG_INSTRUCTION_CLASS_MASK = 510
    CUPTI_ACTIVITY_FLAG_FLUSH_FORCED = 1
    CUPTI_ACTIVITY_FLAG_SHARED_ACCESS_KIND_SIZE_MASK = 255
    CUPTI_ACTIVITY_FLAG_SHARED_ACCESS_KIND_LOAD = 256
    CUPTI_ACTIVITY_FLAG_MEMSET_ASYNC = 1
    CUPTI_ACTIVITY_FLAG_THRASHING_IN_CPU = 1
    CUPTI_ACTIVITY_FLAG_THROTTLING_IN_CPU = 1
    CUPTI_ACTIVITY_FLAG_FORCE_INT = 2147483647
end

@cenum CUpti_ActivityPCSamplingStallReason::UInt32 begin
    CUPTI_ACTIVITY_PC_SAMPLING_STALL_INVALID = 0
    CUPTI_ACTIVITY_PC_SAMPLING_STALL_NONE = 1
    CUPTI_ACTIVITY_PC_SAMPLING_STALL_INST_FETCH = 2
    CUPTI_ACTIVITY_PC_SAMPLING_STALL_EXEC_DEPENDENCY = 3
    CUPTI_ACTIVITY_PC_SAMPLING_STALL_MEMORY_DEPENDENCY = 4
    CUPTI_ACTIVITY_PC_SAMPLING_STALL_TEXTURE = 5
    CUPTI_ACTIVITY_PC_SAMPLING_STALL_SYNC = 6
    CUPTI_ACTIVITY_PC_SAMPLING_STALL_CONSTANT_MEMORY_DEPENDENCY = 7
    CUPTI_ACTIVITY_PC_SAMPLING_STALL_PIPE_BUSY = 8
    CUPTI_ACTIVITY_PC_SAMPLING_STALL_MEMORY_THROTTLE = 9
    CUPTI_ACTIVITY_PC_SAMPLING_STALL_NOT_SELECTED = 10
    CUPTI_ACTIVITY_PC_SAMPLING_STALL_OTHER = 11
    CUPTI_ACTIVITY_PC_SAMPLING_STALL_SLEEPING = 12
    CUPTI_ACTIVITY_PC_SAMPLING_STALL_FORCE_INT = 2147483647
end

@cenum CUpti_ActivityPCSamplingPeriod::UInt32 begin
    CUPTI_ACTIVITY_PC_SAMPLING_PERIOD_INVALID = 0
    CUPTI_ACTIVITY_PC_SAMPLING_PERIOD_MIN = 1
    CUPTI_ACTIVITY_PC_SAMPLING_PERIOD_LOW = 2
    CUPTI_ACTIVITY_PC_SAMPLING_PERIOD_MID = 3
    CUPTI_ACTIVITY_PC_SAMPLING_PERIOD_HIGH = 4
    CUPTI_ACTIVITY_PC_SAMPLING_PERIOD_MAX = 5
    CUPTI_ACTIVITY_PC_SAMPLING_PERIOD_FORCE_INT = 2147483647
end

@cenum CUpti_ActivityMemcpyKind::UInt32 begin
    CUPTI_ACTIVITY_MEMCPY_KIND_UNKNOWN = 0
    CUPTI_ACTIVITY_MEMCPY_KIND_HTOD = 1
    CUPTI_ACTIVITY_MEMCPY_KIND_DTOH = 2
    CUPTI_ACTIVITY_MEMCPY_KIND_HTOA = 3
    CUPTI_ACTIVITY_MEMCPY_KIND_ATOH = 4
    CUPTI_ACTIVITY_MEMCPY_KIND_ATOA = 5
    CUPTI_ACTIVITY_MEMCPY_KIND_ATOD = 6
    CUPTI_ACTIVITY_MEMCPY_KIND_DTOA = 7
    CUPTI_ACTIVITY_MEMCPY_KIND_DTOD = 8
    CUPTI_ACTIVITY_MEMCPY_KIND_HTOH = 9
    CUPTI_ACTIVITY_MEMCPY_KIND_PTOP = 10
    CUPTI_ACTIVITY_MEMCPY_KIND_FORCE_INT = 2147483647
end

@cenum CUpti_ActivityMemoryKind::UInt32 begin
    CUPTI_ACTIVITY_MEMORY_KIND_UNKNOWN = 0
    CUPTI_ACTIVITY_MEMORY_KIND_PAGEABLE = 1
    CUPTI_ACTIVITY_MEMORY_KIND_PINNED = 2
    CUPTI_ACTIVITY_MEMORY_KIND_DEVICE = 3
    CUPTI_ACTIVITY_MEMORY_KIND_ARRAY = 4
    CUPTI_ACTIVITY_MEMORY_KIND_MANAGED = 5
    CUPTI_ACTIVITY_MEMORY_KIND_DEVICE_STATIC = 6
    CUPTI_ACTIVITY_MEMORY_KIND_MANAGED_STATIC = 7
    CUPTI_ACTIVITY_MEMORY_KIND_FORCE_INT = 2147483647
end

@cenum CUpti_ActivityPreemptionKind::UInt32 begin
    CUPTI_ACTIVITY_PREEMPTION_KIND_UNKNOWN = 0
    CUPTI_ACTIVITY_PREEMPTION_KIND_SAVE = 1
    CUPTI_ACTIVITY_PREEMPTION_KIND_RESTORE = 2
    CUPTI_ACTIVITY_PREEMPTION_KIND_FORCE_INT = 2147483647
end

@cenum CUpti_ActivityEnvironmentKind::UInt32 begin
    CUPTI_ACTIVITY_ENVIRONMENT_UNKNOWN = 0
    CUPTI_ACTIVITY_ENVIRONMENT_SPEED = 1
    CUPTI_ACTIVITY_ENVIRONMENT_TEMPERATURE = 2
    CUPTI_ACTIVITY_ENVIRONMENT_POWER = 3
    CUPTI_ACTIVITY_ENVIRONMENT_COOLING = 4
    CUPTI_ACTIVITY_ENVIRONMENT_COUNT = 5
    CUPTI_ACTIVITY_ENVIRONMENT_KIND_FORCE_INT = 2147483647
end

@cenum CUpti_EnvironmentClocksThrottleReason::UInt32 begin
    CUPTI_CLOCKS_THROTTLE_REASON_GPU_IDLE = 1
    CUPTI_CLOCKS_THROTTLE_REASON_USER_DEFINED_CLOCKS = 2
    CUPTI_CLOCKS_THROTTLE_REASON_SW_POWER_CAP = 4
    CUPTI_CLOCKS_THROTTLE_REASON_HW_SLOWDOWN = 8
    CUPTI_CLOCKS_THROTTLE_REASON_UNKNOWN = 0x0000000080000000
    CUPTI_CLOCKS_THROTTLE_REASON_UNSUPPORTED = 1073741824
    CUPTI_CLOCKS_THROTTLE_REASON_NONE = 0
    CUPTI_CLOCKS_THROTTLE_REASON_FORCE_INT = 2147483647
end

@cenum CUpti_ActivityUnifiedMemoryCounterScope::UInt32 begin
    CUPTI_ACTIVITY_UNIFIED_MEMORY_COUNTER_SCOPE_UNKNOWN = 0
    CUPTI_ACTIVITY_UNIFIED_MEMORY_COUNTER_SCOPE_PROCESS_SINGLE_DEVICE = 1
    CUPTI_ACTIVITY_UNIFIED_MEMORY_COUNTER_SCOPE_PROCESS_ALL_DEVICES = 2
    CUPTI_ACTIVITY_UNIFIED_MEMORY_COUNTER_SCOPE_COUNT = 3
    CUPTI_ACTIVITY_UNIFIED_MEMORY_COUNTER_SCOPE_FORCE_INT = 2147483647
end

@cenum CUpti_ActivityUnifiedMemoryCounterKind::UInt32 begin
    CUPTI_ACTIVITY_UNIFIED_MEMORY_COUNTER_KIND_UNKNOWN = 0
    CUPTI_ACTIVITY_UNIFIED_MEMORY_COUNTER_KIND_BYTES_TRANSFER_HTOD = 1
    CUPTI_ACTIVITY_UNIFIED_MEMORY_COUNTER_KIND_BYTES_TRANSFER_DTOH = 2
    CUPTI_ACTIVITY_UNIFIED_MEMORY_COUNTER_KIND_CPU_PAGE_FAULT_COUNT = 3
    CUPTI_ACTIVITY_UNIFIED_MEMORY_COUNTER_KIND_GPU_PAGE_FAULT = 4
    CUPTI_ACTIVITY_UNIFIED_MEMORY_COUNTER_KIND_THRASHING = 5
    CUPTI_ACTIVITY_UNIFIED_MEMORY_COUNTER_KIND_THROTTLING = 6
    CUPTI_ACTIVITY_UNIFIED_MEMORY_COUNTER_KIND_REMOTE_MAP = 7
    CUPTI_ACTIVITY_UNIFIED_MEMORY_COUNTER_KIND_BYTES_TRANSFER_DTOD = 8
    CUPTI_ACTIVITY_UNIFIED_MEMORY_COUNTER_KIND_COUNT = 9
    CUPTI_ACTIVITY_UNIFIED_MEMORY_COUNTER_KIND_FORCE_INT = 2147483647
end

@cenum CUpti_ActivityUnifiedMemoryAccessType::UInt32 begin
    CUPTI_ACTIVITY_UNIFIED_MEMORY_ACCESS_TYPE_UNKNOWN = 0
    CUPTI_ACTIVITY_UNIFIED_MEMORY_ACCESS_TYPE_READ = 1
    CUPTI_ACTIVITY_UNIFIED_MEMORY_ACCESS_TYPE_WRITE = 2
    CUPTI_ACTIVITY_UNIFIED_MEMORY_ACCESS_TYPE_ATOMIC = 3
    CUPTI_ACTIVITY_UNIFIED_MEMORY_ACCESS_TYPE_PREFETCH = 4
end

@cenum CUpti_ActivityUnifiedMemoryMigrationCause::UInt32 begin
    CUPTI_ACTIVITY_UNIFIED_MEMORY_MIGRATION_CAUSE_UNKNOWN = 0
    CUPTI_ACTIVITY_UNIFIED_MEMORY_MIGRATION_CAUSE_USER = 1
    CUPTI_ACTIVITY_UNIFIED_MEMORY_MIGRATION_CAUSE_COHERENCE = 2
    CUPTI_ACTIVITY_UNIFIED_MEMORY_MIGRATION_CAUSE_PREFETCH = 3
    CUPTI_ACTIVITY_UNIFIED_MEMORY_MIGRATION_CAUSE_EVICTION = 4
    CUPTI_ACTIVITY_UNIFIED_MEMORY_MIGRATION_CAUSE_ACCESS_COUNTERS = 5
end

@cenum CUpti_ActivityUnifiedMemoryRemoteMapCause::UInt32 begin
    CUPTI_ACTIVITY_UNIFIED_MEMORY_REMOTE_MAP_CAUSE_UNKNOWN = 0
    CUPTI_ACTIVITY_UNIFIED_MEMORY_REMOTE_MAP_CAUSE_COHERENCE = 1
    CUPTI_ACTIVITY_UNIFIED_MEMORY_REMOTE_MAP_CAUSE_THRASHING = 2
    CUPTI_ACTIVITY_UNIFIED_MEMORY_REMOTE_MAP_CAUSE_POLICY = 3
    CUPTI_ACTIVITY_UNIFIED_MEMORY_REMOTE_MAP_CAUSE_OUT_OF_MEMORY = 4
    CUPTI_ACTIVITY_UNIFIED_MEMORY_REMOTE_MAP_CAUSE_EVICTION = 5
end

@cenum CUpti_ActivityInstructionClass::UInt32 begin
    CUPTI_ACTIVITY_INSTRUCTION_CLASS_UNKNOWN = 0
    CUPTI_ACTIVITY_INSTRUCTION_CLASS_FP_32 = 1
    CUPTI_ACTIVITY_INSTRUCTION_CLASS_FP_64 = 2
    CUPTI_ACTIVITY_INSTRUCTION_CLASS_INTEGER = 3
    CUPTI_ACTIVITY_INSTRUCTION_CLASS_BIT_CONVERSION = 4
    CUPTI_ACTIVITY_INSTRUCTION_CLASS_CONTROL_FLOW = 5
    CUPTI_ACTIVITY_INSTRUCTION_CLASS_GLOBAL = 6
    CUPTI_ACTIVITY_INSTRUCTION_CLASS_SHARED = 7
    CUPTI_ACTIVITY_INSTRUCTION_CLASS_LOCAL = 8
    CUPTI_ACTIVITY_INSTRUCTION_CLASS_GENERIC = 9
    CUPTI_ACTIVITY_INSTRUCTION_CLASS_SURFACE = 10
    CUPTI_ACTIVITY_INSTRUCTION_CLASS_CONSTANT = 11
    CUPTI_ACTIVITY_INSTRUCTION_CLASS_TEXTURE = 12
    CUPTI_ACTIVITY_INSTRUCTION_CLASS_GLOBAL_ATOMIC = 13
    CUPTI_ACTIVITY_INSTRUCTION_CLASS_SHARED_ATOMIC = 14
    CUPTI_ACTIVITY_INSTRUCTION_CLASS_SURFACE_ATOMIC = 15
    CUPTI_ACTIVITY_INSTRUCTION_CLASS_INTER_THREAD_COMMUNICATION = 16
    CUPTI_ACTIVITY_INSTRUCTION_CLASS_BARRIER = 17
    CUPTI_ACTIVITY_INSTRUCTION_CLASS_MISCELLANEOUS = 18
    CUPTI_ACTIVITY_INSTRUCTION_CLASS_FP_16 = 19
    CUPTI_ACTIVITY_INSTRUCTION_CLASS_UNIFORM = 20
    CUPTI_ACTIVITY_INSTRUCTION_CLASS_KIND_FORCE_INT = 2147483647
end

@cenum CUpti_ActivityPartitionedGlobalCacheConfig::UInt32 begin
    CUPTI_ACTIVITY_PARTITIONED_GLOBAL_CACHE_CONFIG_UNKNOWN = 0
    CUPTI_ACTIVITY_PARTITIONED_GLOBAL_CACHE_CONFIG_NOT_SUPPORTED = 1
    CUPTI_ACTIVITY_PARTITIONED_GLOBAL_CACHE_CONFIG_OFF = 2
    CUPTI_ACTIVITY_PARTITIONED_GLOBAL_CACHE_CONFIG_ON = 3
    CUPTI_ACTIVITY_PARTITIONED_GLOBAL_CACHE_CONFIG_FORCE_INT = 2147483647
end

@cenum CUpti_ActivitySynchronizationType::UInt32 begin
    CUPTI_ACTIVITY_SYNCHRONIZATION_TYPE_UNKNOWN = 0
    CUPTI_ACTIVITY_SYNCHRONIZATION_TYPE_EVENT_SYNCHRONIZE = 1
    CUPTI_ACTIVITY_SYNCHRONIZATION_TYPE_STREAM_WAIT_EVENT = 2
    CUPTI_ACTIVITY_SYNCHRONIZATION_TYPE_STREAM_SYNCHRONIZE = 3
    CUPTI_ACTIVITY_SYNCHRONIZATION_TYPE_CONTEXT_SYNCHRONIZE = 4
    CUPTI_ACTIVITY_SYNCHRONIZATION_TYPE_FORCE_INT = 2147483647
end

@cenum CUpti_ActivityStreamFlag::UInt32 begin
    CUPTI_ACTIVITY_STREAM_CREATE_FLAG_UNKNOWN = 0
    CUPTI_ACTIVITY_STREAM_CREATE_FLAG_DEFAULT = 1
    CUPTI_ACTIVITY_STREAM_CREATE_FLAG_NON_BLOCKING = 2
    CUPTI_ACTIVITY_STREAM_CREATE_FLAG_NULL = 3
    CUPTI_ACTIVITY_STREAM_CREATE_MASK = 65535
    CUPTI_ACTIVITY_STREAM_CREATE_FLAG_FORCE_INT = 2147483647
end

@cenum CUpti_LinkFlag::UInt32 begin
    CUPTI_LINK_FLAG_INVALID = 0
    CUPTI_LINK_FLAG_PEER_ACCESS = 2
    CUPTI_LINK_FLAG_SYSMEM_ACCESS = 4
    CUPTI_LINK_FLAG_PEER_ATOMICS = 8
    CUPTI_LINK_FLAG_SYSMEM_ATOMICS = 16
    CUPTI_LINK_FLAG_FORCE_INT = 2147483647
end

@cenum CUpti_ActivityMemoryOperationType::UInt32 begin
    CUPTI_ACTIVITY_MEMORY_OPERATION_TYPE_INVALID = 0
    CUPTI_ACTIVITY_MEMORY_OPERATION_TYPE_ALLOCATION = 1
    CUPTI_ACTIVITY_MEMORY_OPERATION_TYPE_RELEASE = 2
    CUPTI_ACTIVITY_MEMORY_OPERATION_TYPE_FORCE_INT = 2147483647
end

@cenum CUpti_ActivityMemoryPoolType::UInt32 begin
    CUPTI_ACTIVITY_MEMORY_POOL_TYPE_INVALID = 0
    CUPTI_ACTIVITY_MEMORY_POOL_TYPE_LOCAL = 1
    CUPTI_ACTIVITY_MEMORY_POOL_TYPE_IMPORTED = 2
    CUPTI_ACTIVITY_MEMORY_POOL_TYPE_FORCE_INT = 2147483647
end

@cenum CUpti_ActivityMemoryPoolOperationType::UInt32 begin
    CUPTI_ACTIVITY_MEMORY_POOL_OPERATION_TYPE_INVALID = 0
    CUPTI_ACTIVITY_MEMORY_POOL_OPERATION_TYPE_CREATED = 1
    CUPTI_ACTIVITY_MEMORY_POOL_OPERATION_TYPE_DESTROYED = 2
    CUPTI_ACTIVITY_MEMORY_POOL_OPERATION_TYPE_TRIMMED = 3
    CUPTI_ACTIVITY_MEMORY_POOL_OPERATION_TYPE_FORCE_INT = 2147483647
end

@cenum CUpti_ChannelType::UInt32 begin
    CUPTI_CHANNEL_TYPE_INVALID = 0
    CUPTI_CHANNEL_TYPE_COMPUTE = 1
    CUPTI_CHANNEL_TYPE_ASYNC_MEMCPY = 2
end

struct CUpti_ActivityUnifiedMemoryCounterConfig
    scope::CUpti_ActivityUnifiedMemoryCounterScope
    kind::CUpti_ActivityUnifiedMemoryCounterKind
    deviceId::UInt32
    enable::UInt32
end

struct CUpti_ActivityAutoBoostState
    enabled::UInt32
    pid::UInt32
end

struct CUpti_ActivityPCSamplingConfig
    size::UInt32
    samplingPeriod::CUpti_ActivityPCSamplingPeriod
    samplingPeriod2::UInt32
end

struct CUpti_Activity
    kind::CUpti_ActivityKind
end

struct CUpti_ActivityMemcpy
    kind::CUpti_ActivityKind
    copyKind::UInt8
    srcKind::UInt8
    dstKind::UInt8
    flags::UInt8
    bytes::UInt64
    start::UInt64
    _end::UInt64
    deviceId::UInt32
    contextId::UInt32
    streamId::UInt32
    correlationId::UInt32
    runtimeCorrelationId::UInt32
    pad::UInt32
    reserved0::Ptr{Cvoid}
end

struct CUpti_ActivityMemcpy3
    kind::CUpti_ActivityKind
    copyKind::UInt8
    srcKind::UInt8
    dstKind::UInt8
    flags::UInt8
    bytes::UInt64
    start::UInt64
    _end::UInt64
    deviceId::UInt32
    contextId::UInt32
    streamId::UInt32
    correlationId::UInt32
    runtimeCorrelationId::UInt32
    pad::UInt32
    reserved0::Ptr{Cvoid}
    graphNodeId::UInt64
end

struct CUpti_ActivityMemcpy4
    kind::CUpti_ActivityKind
    copyKind::UInt8
    srcKind::UInt8
    dstKind::UInt8
    flags::UInt8
    bytes::UInt64
    start::UInt64
    _end::UInt64
    deviceId::UInt32
    contextId::UInt32
    streamId::UInt32
    correlationId::UInt32
    runtimeCorrelationId::UInt32
    pad::UInt32
    reserved0::Ptr{Cvoid}
    graphNodeId::UInt64
    graphId::UInt32
    padding::UInt32
end

struct CUpti_ActivityMemcpy5
    kind::CUpti_ActivityKind
    copyKind::UInt8
    srcKind::UInt8
    dstKind::UInt8
    flags::UInt8
    bytes::UInt64
    start::UInt64
    _end::UInt64
    deviceId::UInt32
    contextId::UInt32
    streamId::UInt32
    correlationId::UInt32
    runtimeCorrelationId::UInt32
    pad::UInt32
    reserved0::Ptr{Cvoid}
    graphNodeId::UInt64
    graphId::UInt32
    channelID::UInt32
    channelType::CUpti_ChannelType
    pad2::UInt32
end

struct CUpti_ActivityMemcpyPtoP
    kind::CUpti_ActivityKind
    copyKind::UInt8
    srcKind::UInt8
    dstKind::UInt8
    flags::UInt8
    bytes::UInt64
    start::UInt64
    _end::UInt64
    deviceId::UInt32
    contextId::UInt32
    streamId::UInt32
    srcDeviceId::UInt32
    srcContextId::UInt32
    dstDeviceId::UInt32
    dstContextId::UInt32
    correlationId::UInt32
    reserved0::Ptr{Cvoid}
end

const CUpti_ActivityMemcpy2 = CUpti_ActivityMemcpyPtoP

struct CUpti_ActivityMemcpyPtoP2
    kind::CUpti_ActivityKind
    copyKind::UInt8
    srcKind::UInt8
    dstKind::UInt8
    flags::UInt8
    bytes::UInt64
    start::UInt64
    _end::UInt64
    deviceId::UInt32
    contextId::UInt32
    streamId::UInt32
    srcDeviceId::UInt32
    srcContextId::UInt32
    dstDeviceId::UInt32
    dstContextId::UInt32
    correlationId::UInt32
    reserved0::Ptr{Cvoid}
    graphNodeId::UInt64
end

struct CUpti_ActivityMemcpyPtoP3
    kind::CUpti_ActivityKind
    copyKind::UInt8
    srcKind::UInt8
    dstKind::UInt8
    flags::UInt8
    bytes::UInt64
    start::UInt64
    _end::UInt64
    deviceId::UInt32
    contextId::UInt32
    streamId::UInt32
    srcDeviceId::UInt32
    srcContextId::UInt32
    dstDeviceId::UInt32
    dstContextId::UInt32
    correlationId::UInt32
    reserved0::Ptr{Cvoid}
    graphNodeId::UInt64
    graphId::UInt32
    padding::UInt32
end

struct CUpti_ActivityMemcpyPtoP4
    kind::CUpti_ActivityKind
    copyKind::UInt8
    srcKind::UInt8
    dstKind::UInt8
    flags::UInt8
    bytes::UInt64
    start::UInt64
    _end::UInt64
    deviceId::UInt32
    contextId::UInt32
    streamId::UInt32
    srcDeviceId::UInt32
    srcContextId::UInt32
    dstDeviceId::UInt32
    dstContextId::UInt32
    correlationId::UInt32
    reserved0::Ptr{Cvoid}
    graphNodeId::UInt64
    graphId::UInt32
    channelID::UInt32
    channelType::CUpti_ChannelType
end

struct CUpti_ActivityMemset
    kind::CUpti_ActivityKind
    value::UInt32
    bytes::UInt64
    start::UInt64
    _end::UInt64
    deviceId::UInt32
    contextId::UInt32
    streamId::UInt32
    correlationId::UInt32
    flags::UInt16
    memoryKind::UInt16
    pad::UInt32
    reserved0::Ptr{Cvoid}
end

struct CUpti_ActivityMemset2
    kind::CUpti_ActivityKind
    value::UInt32
    bytes::UInt64
    start::UInt64
    _end::UInt64
    deviceId::UInt32
    contextId::UInt32
    streamId::UInt32
    correlationId::UInt32
    flags::UInt16
    memoryKind::UInt16
    pad::UInt32
    reserved0::Ptr{Cvoid}
    graphNodeId::UInt64
end

struct CUpti_ActivityMemset3
    kind::CUpti_ActivityKind
    value::UInt32
    bytes::UInt64
    start::UInt64
    _end::UInt64
    deviceId::UInt32
    contextId::UInt32
    streamId::UInt32
    correlationId::UInt32
    flags::UInt16
    memoryKind::UInt16
    pad::UInt32
    reserved0::Ptr{Cvoid}
    graphNodeId::UInt64
    graphId::UInt32
    padding::UInt32
end

struct CUpti_ActivityMemset4
    kind::CUpti_ActivityKind
    value::UInt32
    bytes::UInt64
    start::UInt64
    _end::UInt64
    deviceId::UInt32
    contextId::UInt32
    streamId::UInt32
    correlationId::UInt32
    flags::UInt16
    memoryKind::UInt16
    pad::UInt32
    reserved0::Ptr{Cvoid}
    graphNodeId::UInt64
    graphId::UInt32
    channelID::UInt32
    channelType::CUpti_ChannelType
    pad2::UInt32
end

struct CUpti_ActivityMemory
    kind::CUpti_ActivityKind
    memoryKind::CUpti_ActivityMemoryKind
    address::UInt64
    bytes::UInt64
    start::UInt64
    _end::UInt64
    allocPC::UInt64
    freePC::UInt64
    processId::UInt32
    deviceId::UInt32
    contextId::UInt32
    pad::UInt32
    name::Cstring
end

struct var"##Ctag#728"
    data::NTuple{8,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#728"}, f::Symbol)
    f === :size && return Ptr{UInt64}(x + 0)
    f === :processId && return Ptr{UInt64}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#728", f::Symbol)
    r = Ref{var"##Ctag#728"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#728"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#728"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#727"
    data::NTuple{32,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#727"}, f::Symbol)
    f === :memoryPoolType && return Ptr{CUpti_ActivityMemoryPoolType}(x + 0)
    f === :pad2 && return Ptr{UInt32}(x + 4)
    f === :address && return Ptr{UInt64}(x + 8)
    f === :releaseThreshold && return Ptr{UInt64}(x + 16)
    f === :pool && return Ptr{var"##Ctag#728"}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#727", f::Symbol)
    r = Ref{var"##Ctag#727"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#727"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#727"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct CUpti_ActivityMemory2
    data::NTuple{112,UInt8}
end

function Base.getproperty(x::Ptr{CUpti_ActivityMemory2}, f::Symbol)
    f === :kind && return Ptr{CUpti_ActivityKind}(x + 0)
    f === :memoryOperationType && return Ptr{CUpti_ActivityMemoryOperationType}(x + 4)
    f === :memoryKind && return Ptr{CUpti_ActivityMemoryKind}(x + 8)
    f === :correlationId && return Ptr{UInt32}(x + 12)
    f === :address && return Ptr{UInt64}(x + 16)
    f === :bytes && return Ptr{UInt64}(x + 24)
    f === :timestamp && return Ptr{UInt64}(x + 32)
    f === :PC && return Ptr{UInt64}(x + 40)
    f === :processId && return Ptr{UInt32}(x + 48)
    f === :deviceId && return Ptr{UInt32}(x + 52)
    f === :contextId && return Ptr{UInt32}(x + 56)
    f === :streamId && return Ptr{UInt32}(x + 60)
    f === :name && return Ptr{Cstring}(x + 64)
    f === :isAsync && return Ptr{UInt32}(x + 72)
    f === :pad1 && return Ptr{UInt32}(x + 76)
    f === :memoryPoolConfig && return Ptr{Cvoid}(x + 80)
    return getfield(x, f)
end

function Base.getproperty(x::CUpti_ActivityMemory2, f::Symbol)
    r = Ref{CUpti_ActivityMemory2}(x)
    ptr = Base.unsafe_convert(Ptr{CUpti_ActivityMemory2}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{CUpti_ActivityMemory2}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#716"
    data::NTuple{8,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#716"}, f::Symbol)
    f === :size && return Ptr{UInt64}(x + 0)
    f === :processId && return Ptr{UInt64}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#716", f::Symbol)
    r = Ref{var"##Ctag#716"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#716"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#716"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#715"
    data::NTuple{40,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#715"}, f::Symbol)
    f === :memoryPoolType && return Ptr{CUpti_ActivityMemoryPoolType}(x + 0)
    f === :pad2 && return Ptr{UInt32}(x + 4)
    f === :address && return Ptr{UInt64}(x + 8)
    f === :releaseThreshold && return Ptr{UInt64}(x + 16)
    f === :pool && return Ptr{var"##Ctag#716"}(x + 24)
    f === :utilizedSize && return Ptr{UInt64}(x + 32)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#715", f::Symbol)
    r = Ref{var"##Ctag#715"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#715"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#715"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct CUpti_ActivityMemory3
    data::NTuple{120,UInt8}
end

function Base.getproperty(x::Ptr{CUpti_ActivityMemory3}, f::Symbol)
    f === :kind && return Ptr{CUpti_ActivityKind}(x + 0)
    f === :memoryOperationType && return Ptr{CUpti_ActivityMemoryOperationType}(x + 4)
    f === :memoryKind && return Ptr{CUpti_ActivityMemoryKind}(x + 8)
    f === :correlationId && return Ptr{UInt32}(x + 12)
    f === :address && return Ptr{UInt64}(x + 16)
    f === :bytes && return Ptr{UInt64}(x + 24)
    f === :timestamp && return Ptr{UInt64}(x + 32)
    f === :PC && return Ptr{UInt64}(x + 40)
    f === :processId && return Ptr{UInt32}(x + 48)
    f === :deviceId && return Ptr{UInt32}(x + 52)
    f === :contextId && return Ptr{UInt32}(x + 56)
    f === :streamId && return Ptr{UInt32}(x + 60)
    f === :name && return Ptr{Cstring}(x + 64)
    f === :isAsync && return Ptr{UInt32}(x + 72)
    f === :pad1 && return Ptr{UInt32}(x + 76)
    f === :memoryPoolConfig && return Ptr{Cvoid}(x + 80)
    return getfield(x, f)
end

function Base.getproperty(x::CUpti_ActivityMemory3, f::Symbol)
    r = Ref{CUpti_ActivityMemory3}(x)
    ptr = Base.unsafe_convert(Ptr{CUpti_ActivityMemory3}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{CUpti_ActivityMemory3}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct CUpti_ActivityMemoryPool
    kind::CUpti_ActivityKind
    memoryPoolOperationType::CUpti_ActivityMemoryPoolOperationType
    memoryPoolType::CUpti_ActivityMemoryPoolType
    correlationId::UInt32
    processId::UInt32
    deviceId::UInt32
    minBytesToKeep::Csize_t
    address::UInt64
    size::UInt64
    releaseThreshold::UInt64
    timestamp::UInt64
end

struct CUpti_ActivityMemoryPool2
    kind::CUpti_ActivityKind
    memoryPoolOperationType::CUpti_ActivityMemoryPoolOperationType
    memoryPoolType::CUpti_ActivityMemoryPoolType
    correlationId::UInt32
    processId::UInt32
    deviceId::UInt32
    minBytesToKeep::Csize_t
    address::UInt64
    size::UInt64
    releaseThreshold::UInt64
    timestamp::UInt64
    utilizedSize::UInt64
end

struct CUpti_ActivityKernel
    kind::CUpti_ActivityKind
    cacheConfigRequested::UInt8
    cacheConfigExecuted::UInt8
    registersPerThread::UInt16
    start::UInt64
    _end::UInt64
    deviceId::UInt32
    contextId::UInt32
    streamId::UInt32
    gridX::Int32
    gridY::Int32
    gridZ::Int32
    blockX::Int32
    blockY::Int32
    blockZ::Int32
    staticSharedMemory::Int32
    dynamicSharedMemory::Int32
    localMemoryPerThread::UInt32
    localMemoryTotal::UInt32
    correlationId::UInt32
    runtimeCorrelationId::UInt32
    pad::UInt32
    name::Cstring
    reserved0::Ptr{Cvoid}
end

struct var"##Ctag#735"
    data::NTuple{1,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#735"}, f::Symbol)
    f === :both && return Ptr{UInt8}(x + 0)
    f === :config && return Ptr{var"##Ctag#736"}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#735", f::Symbol)
    r = Ref{var"##Ctag#735"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#735"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#735"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct CUpti_ActivityKernel2
    data::NTuple{112,UInt8}
end

function Base.getproperty(x::Ptr{CUpti_ActivityKernel2}, f::Symbol)
    f === :kind && return Ptr{CUpti_ActivityKind}(x + 0)
    f === :cacheConfig && return Ptr{var"##Ctag#735"}(x + 4)
    f === :sharedMemoryConfig && return Ptr{UInt8}(x + 5)
    f === :registersPerThread && return Ptr{UInt16}(x + 6)
    f === :start && return Ptr{UInt64}(x + 8)
    f === :_end && return Ptr{UInt64}(x + 16)
    f === :completed && return Ptr{UInt64}(x + 24)
    f === :deviceId && return Ptr{UInt32}(x + 32)
    f === :contextId && return Ptr{UInt32}(x + 36)
    f === :streamId && return Ptr{UInt32}(x + 40)
    f === :gridX && return Ptr{Int32}(x + 44)
    f === :gridY && return Ptr{Int32}(x + 48)
    f === :gridZ && return Ptr{Int32}(x + 52)
    f === :blockX && return Ptr{Int32}(x + 56)
    f === :blockY && return Ptr{Int32}(x + 60)
    f === :blockZ && return Ptr{Int32}(x + 64)
    f === :staticSharedMemory && return Ptr{Int32}(x + 68)
    f === :dynamicSharedMemory && return Ptr{Int32}(x + 72)
    f === :localMemoryPerThread && return Ptr{UInt32}(x + 76)
    f === :localMemoryTotal && return Ptr{UInt32}(x + 80)
    f === :correlationId && return Ptr{UInt32}(x + 84)
    f === :gridId && return Ptr{Int64}(x + 88)
    f === :name && return Ptr{Cstring}(x + 96)
    f === :reserved0 && return Ptr{Ptr{Cvoid}}(x + 104)
    return getfield(x, f)
end

function Base.getproperty(x::CUpti_ActivityKernel2, f::Symbol)
    r = Ref{CUpti_ActivityKernel2}(x)
    ptr = Base.unsafe_convert(Ptr{CUpti_ActivityKernel2}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{CUpti_ActivityKernel2}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#769"
    data::NTuple{1,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#769"}, f::Symbol)
    f === :both && return Ptr{UInt8}(x + 0)
    f === :config && return Ptr{var"##Ctag#770"}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#769", f::Symbol)
    r = Ref{var"##Ctag#769"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#769"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#769"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct CUpti_ActivityKernel3
    data::NTuple{120,UInt8}
end

function Base.getproperty(x::Ptr{CUpti_ActivityKernel3}, f::Symbol)
    f === :kind && return Ptr{CUpti_ActivityKind}(x + 0)
    f === :cacheConfig && return Ptr{var"##Ctag#769"}(x + 4)
    f === :sharedMemoryConfig && return Ptr{UInt8}(x + 5)
    f === :registersPerThread && return Ptr{UInt16}(x + 6)
    f === :partitionedGlobalCacheRequested &&
        return Ptr{CUpti_ActivityPartitionedGlobalCacheConfig}(x + 8)
    f === :partitionedGlobalCacheExecuted &&
        return Ptr{CUpti_ActivityPartitionedGlobalCacheConfig}(x + 12)
    f === :start && return Ptr{UInt64}(x + 16)
    f === :_end && return Ptr{UInt64}(x + 24)
    f === :completed && return Ptr{UInt64}(x + 32)
    f === :deviceId && return Ptr{UInt32}(x + 40)
    f === :contextId && return Ptr{UInt32}(x + 44)
    f === :streamId && return Ptr{UInt32}(x + 48)
    f === :gridX && return Ptr{Int32}(x + 52)
    f === :gridY && return Ptr{Int32}(x + 56)
    f === :gridZ && return Ptr{Int32}(x + 60)
    f === :blockX && return Ptr{Int32}(x + 64)
    f === :blockY && return Ptr{Int32}(x + 68)
    f === :blockZ && return Ptr{Int32}(x + 72)
    f === :staticSharedMemory && return Ptr{Int32}(x + 76)
    f === :dynamicSharedMemory && return Ptr{Int32}(x + 80)
    f === :localMemoryPerThread && return Ptr{UInt32}(x + 84)
    f === :localMemoryTotal && return Ptr{UInt32}(x + 88)
    f === :correlationId && return Ptr{UInt32}(x + 92)
    f === :gridId && return Ptr{Int64}(x + 96)
    f === :name && return Ptr{Cstring}(x + 104)
    f === :reserved0 && return Ptr{Ptr{Cvoid}}(x + 112)
    return getfield(x, f)
end

function Base.getproperty(x::CUpti_ActivityKernel3, f::Symbol)
    r = Ref{CUpti_ActivityKernel3}(x)
    ptr = Base.unsafe_convert(Ptr{CUpti_ActivityKernel3}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{CUpti_ActivityKernel3}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

@cenum CUpti_ActivityLaunchType::UInt32 begin
    CUPTI_ACTIVITY_LAUNCH_TYPE_REGULAR = 0
    CUPTI_ACTIVITY_LAUNCH_TYPE_COOPERATIVE_SINGLE_DEVICE = 1
    CUPTI_ACTIVITY_LAUNCH_TYPE_COOPERATIVE_MULTI_DEVICE = 2
end

struct var"##Ctag#760"
    data::NTuple{1,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#760"}, f::Symbol)
    f === :both && return Ptr{UInt8}(x + 0)
    f === :config && return Ptr{var"##Ctag#761"}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#760", f::Symbol)
    r = Ref{var"##Ctag#760"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#760"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#760"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct CUpti_ActivityKernel4
    data::NTuple{144,UInt8}
end

function Base.getproperty(x::Ptr{CUpti_ActivityKernel4}, f::Symbol)
    f === :kind && return Ptr{CUpti_ActivityKind}(x + 0)
    f === :cacheConfig && return Ptr{var"##Ctag#760"}(x + 4)
    f === :sharedMemoryConfig && return Ptr{UInt8}(x + 5)
    f === :registersPerThread && return Ptr{UInt16}(x + 6)
    f === :partitionedGlobalCacheRequested &&
        return Ptr{CUpti_ActivityPartitionedGlobalCacheConfig}(x + 8)
    f === :partitionedGlobalCacheExecuted &&
        return Ptr{CUpti_ActivityPartitionedGlobalCacheConfig}(x + 12)
    f === :start && return Ptr{UInt64}(x + 16)
    f === :_end && return Ptr{UInt64}(x + 24)
    f === :completed && return Ptr{UInt64}(x + 32)
    f === :deviceId && return Ptr{UInt32}(x + 40)
    f === :contextId && return Ptr{UInt32}(x + 44)
    f === :streamId && return Ptr{UInt32}(x + 48)
    f === :gridX && return Ptr{Int32}(x + 52)
    f === :gridY && return Ptr{Int32}(x + 56)
    f === :gridZ && return Ptr{Int32}(x + 60)
    f === :blockX && return Ptr{Int32}(x + 64)
    f === :blockY && return Ptr{Int32}(x + 68)
    f === :blockZ && return Ptr{Int32}(x + 72)
    f === :staticSharedMemory && return Ptr{Int32}(x + 76)
    f === :dynamicSharedMemory && return Ptr{Int32}(x + 80)
    f === :localMemoryPerThread && return Ptr{UInt32}(x + 84)
    f === :localMemoryTotal && return Ptr{UInt32}(x + 88)
    f === :correlationId && return Ptr{UInt32}(x + 92)
    f === :gridId && return Ptr{Int64}(x + 96)
    f === :name && return Ptr{Cstring}(x + 104)
    f === :reserved0 && return Ptr{Ptr{Cvoid}}(x + 112)
    f === :queued && return Ptr{UInt64}(x + 120)
    f === :submitted && return Ptr{UInt64}(x + 128)
    f === :launchType && return Ptr{UInt8}(x + 136)
    f === :isSharedMemoryCarveoutRequested && return Ptr{UInt8}(x + 137)
    f === :sharedMemoryCarveoutRequested && return Ptr{UInt8}(x + 138)
    f === :padding && return Ptr{UInt8}(x + 139)
    f === :sharedMemoryExecuted && return Ptr{UInt32}(x + 140)
    return getfield(x, f)
end

function Base.getproperty(x::CUpti_ActivityKernel4, f::Symbol)
    r = Ref{CUpti_ActivityKernel4}(x)
    ptr = Base.unsafe_convert(Ptr{CUpti_ActivityKernel4}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{CUpti_ActivityKernel4}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

@cenum CUpti_FuncShmemLimitConfig::UInt32 begin
    CUPTI_FUNC_SHMEM_LIMIT_DEFAULT = 0
    CUPTI_FUNC_SHMEM_LIMIT_OPTIN = 1
    CUPTI_FUNC_SHMEM_LIMIT_FORCE_INT = 2147483647
end

struct var"##Ctag#718"
    data::NTuple{1,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#718"}, f::Symbol)
    f === :both && return Ptr{UInt8}(x + 0)
    f === :config && return Ptr{var"##Ctag#719"}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#718", f::Symbol)
    r = Ref{var"##Ctag#718"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#718"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#718"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct CUpti_ActivityKernel5
    data::NTuple{160,UInt8}
end

function Base.getproperty(x::Ptr{CUpti_ActivityKernel5}, f::Symbol)
    f === :kind && return Ptr{CUpti_ActivityKind}(x + 0)
    f === :cacheConfig && return Ptr{var"##Ctag#718"}(x + 4)
    f === :sharedMemoryConfig && return Ptr{UInt8}(x + 5)
    f === :registersPerThread && return Ptr{UInt16}(x + 6)
    f === :partitionedGlobalCacheRequested &&
        return Ptr{CUpti_ActivityPartitionedGlobalCacheConfig}(x + 8)
    f === :partitionedGlobalCacheExecuted &&
        return Ptr{CUpti_ActivityPartitionedGlobalCacheConfig}(x + 12)
    f === :start && return Ptr{UInt64}(x + 16)
    f === :_end && return Ptr{UInt64}(x + 24)
    f === :completed && return Ptr{UInt64}(x + 32)
    f === :deviceId && return Ptr{UInt32}(x + 40)
    f === :contextId && return Ptr{UInt32}(x + 44)
    f === :streamId && return Ptr{UInt32}(x + 48)
    f === :gridX && return Ptr{Int32}(x + 52)
    f === :gridY && return Ptr{Int32}(x + 56)
    f === :gridZ && return Ptr{Int32}(x + 60)
    f === :blockX && return Ptr{Int32}(x + 64)
    f === :blockY && return Ptr{Int32}(x + 68)
    f === :blockZ && return Ptr{Int32}(x + 72)
    f === :staticSharedMemory && return Ptr{Int32}(x + 76)
    f === :dynamicSharedMemory && return Ptr{Int32}(x + 80)
    f === :localMemoryPerThread && return Ptr{UInt32}(x + 84)
    f === :localMemoryTotal && return Ptr{UInt32}(x + 88)
    f === :correlationId && return Ptr{UInt32}(x + 92)
    f === :gridId && return Ptr{Int64}(x + 96)
    f === :name && return Ptr{Cstring}(x + 104)
    f === :reserved0 && return Ptr{Ptr{Cvoid}}(x + 112)
    f === :queued && return Ptr{UInt64}(x + 120)
    f === :submitted && return Ptr{UInt64}(x + 128)
    f === :launchType && return Ptr{UInt8}(x + 136)
    f === :isSharedMemoryCarveoutRequested && return Ptr{UInt8}(x + 137)
    f === :sharedMemoryCarveoutRequested && return Ptr{UInt8}(x + 138)
    f === :padding && return Ptr{UInt8}(x + 139)
    f === :sharedMemoryExecuted && return Ptr{UInt32}(x + 140)
    f === :graphNodeId && return Ptr{UInt64}(x + 144)
    f === :shmemLimitConfig && return Ptr{CUpti_FuncShmemLimitConfig}(x + 152)
    f === :graphId && return Ptr{UInt32}(x + 156)
    return getfield(x, f)
end

function Base.getproperty(x::CUpti_ActivityKernel5, f::Symbol)
    r = Ref{CUpti_ActivityKernel5}(x)
    ptr = Base.unsafe_convert(Ptr{CUpti_ActivityKernel5}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{CUpti_ActivityKernel5}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#725"
    data::NTuple{1,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#725"}, f::Symbol)
    f === :both && return Ptr{UInt8}(x + 0)
    f === :config && return Ptr{var"##Ctag#726"}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#725", f::Symbol)
    r = Ref{var"##Ctag#725"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#725"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#725"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct CUpti_ActivityKernel6
    data::NTuple{168,UInt8}
end

function Base.getproperty(x::Ptr{CUpti_ActivityKernel6}, f::Symbol)
    f === :kind && return Ptr{CUpti_ActivityKind}(x + 0)
    f === :cacheConfig && return Ptr{var"##Ctag#725"}(x + 4)
    f === :sharedMemoryConfig && return Ptr{UInt8}(x + 5)
    f === :registersPerThread && return Ptr{UInt16}(x + 6)
    f === :partitionedGlobalCacheRequested &&
        return Ptr{CUpti_ActivityPartitionedGlobalCacheConfig}(x + 8)
    f === :partitionedGlobalCacheExecuted &&
        return Ptr{CUpti_ActivityPartitionedGlobalCacheConfig}(x + 12)
    f === :start && return Ptr{UInt64}(x + 16)
    f === :_end && return Ptr{UInt64}(x + 24)
    f === :completed && return Ptr{UInt64}(x + 32)
    f === :deviceId && return Ptr{UInt32}(x + 40)
    f === :contextId && return Ptr{UInt32}(x + 44)
    f === :streamId && return Ptr{UInt32}(x + 48)
    f === :gridX && return Ptr{Int32}(x + 52)
    f === :gridY && return Ptr{Int32}(x + 56)
    f === :gridZ && return Ptr{Int32}(x + 60)
    f === :blockX && return Ptr{Int32}(x + 64)
    f === :blockY && return Ptr{Int32}(x + 68)
    f === :blockZ && return Ptr{Int32}(x + 72)
    f === :staticSharedMemory && return Ptr{Int32}(x + 76)
    f === :dynamicSharedMemory && return Ptr{Int32}(x + 80)
    f === :localMemoryPerThread && return Ptr{UInt32}(x + 84)
    f === :localMemoryTotal && return Ptr{UInt32}(x + 88)
    f === :correlationId && return Ptr{UInt32}(x + 92)
    f === :gridId && return Ptr{Int64}(x + 96)
    f === :name && return Ptr{Cstring}(x + 104)
    f === :reserved0 && return Ptr{Ptr{Cvoid}}(x + 112)
    f === :queued && return Ptr{UInt64}(x + 120)
    f === :submitted && return Ptr{UInt64}(x + 128)
    f === :launchType && return Ptr{UInt8}(x + 136)
    f === :isSharedMemoryCarveoutRequested && return Ptr{UInt8}(x + 137)
    f === :sharedMemoryCarveoutRequested && return Ptr{UInt8}(x + 138)
    f === :padding && return Ptr{UInt8}(x + 139)
    f === :sharedMemoryExecuted && return Ptr{UInt32}(x + 140)
    f === :graphNodeId && return Ptr{UInt64}(x + 144)
    f === :shmemLimitConfig && return Ptr{CUpti_FuncShmemLimitConfig}(x + 152)
    f === :graphId && return Ptr{UInt32}(x + 156)
    f === :pAccessPolicyWindow && return Ptr{Ptr{CUaccessPolicyWindow}}(x + 160)
    return getfield(x, f)
end

function Base.getproperty(x::CUpti_ActivityKernel6, f::Symbol)
    r = Ref{CUpti_ActivityKernel6}(x)
    ptr = Base.unsafe_convert(Ptr{CUpti_ActivityKernel6}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{CUpti_ActivityKernel6}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#762"
    data::NTuple{1,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#762"}, f::Symbol)
    f === :both && return Ptr{UInt8}(x + 0)
    f === :config && return Ptr{var"##Ctag#763"}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#762", f::Symbol)
    r = Ref{var"##Ctag#762"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#762"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#762"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct CUpti_ActivityKernel7
    data::NTuple{176,UInt8}
end

function Base.getproperty(x::Ptr{CUpti_ActivityKernel7}, f::Symbol)
    f === :kind && return Ptr{CUpti_ActivityKind}(x + 0)
    f === :cacheConfig && return Ptr{var"##Ctag#762"}(x + 4)
    f === :sharedMemoryConfig && return Ptr{UInt8}(x + 5)
    f === :registersPerThread && return Ptr{UInt16}(x + 6)
    f === :partitionedGlobalCacheRequested &&
        return Ptr{CUpti_ActivityPartitionedGlobalCacheConfig}(x + 8)
    f === :partitionedGlobalCacheExecuted &&
        return Ptr{CUpti_ActivityPartitionedGlobalCacheConfig}(x + 12)
    f === :start && return Ptr{UInt64}(x + 16)
    f === :_end && return Ptr{UInt64}(x + 24)
    f === :completed && return Ptr{UInt64}(x + 32)
    f === :deviceId && return Ptr{UInt32}(x + 40)
    f === :contextId && return Ptr{UInt32}(x + 44)
    f === :streamId && return Ptr{UInt32}(x + 48)
    f === :gridX && return Ptr{Int32}(x + 52)
    f === :gridY && return Ptr{Int32}(x + 56)
    f === :gridZ && return Ptr{Int32}(x + 60)
    f === :blockX && return Ptr{Int32}(x + 64)
    f === :blockY && return Ptr{Int32}(x + 68)
    f === :blockZ && return Ptr{Int32}(x + 72)
    f === :staticSharedMemory && return Ptr{Int32}(x + 76)
    f === :dynamicSharedMemory && return Ptr{Int32}(x + 80)
    f === :localMemoryPerThread && return Ptr{UInt32}(x + 84)
    f === :localMemoryTotal && return Ptr{UInt32}(x + 88)
    f === :correlationId && return Ptr{UInt32}(x + 92)
    f === :gridId && return Ptr{Int64}(x + 96)
    f === :name && return Ptr{Cstring}(x + 104)
    f === :reserved0 && return Ptr{Ptr{Cvoid}}(x + 112)
    f === :queued && return Ptr{UInt64}(x + 120)
    f === :submitted && return Ptr{UInt64}(x + 128)
    f === :launchType && return Ptr{UInt8}(x + 136)
    f === :isSharedMemoryCarveoutRequested && return Ptr{UInt8}(x + 137)
    f === :sharedMemoryCarveoutRequested && return Ptr{UInt8}(x + 138)
    f === :padding && return Ptr{UInt8}(x + 139)
    f === :sharedMemoryExecuted && return Ptr{UInt32}(x + 140)
    f === :graphNodeId && return Ptr{UInt64}(x + 144)
    f === :shmemLimitConfig && return Ptr{CUpti_FuncShmemLimitConfig}(x + 152)
    f === :graphId && return Ptr{UInt32}(x + 156)
    f === :pAccessPolicyWindow && return Ptr{Ptr{CUaccessPolicyWindow}}(x + 160)
    f === :channelID && return Ptr{UInt32}(x + 168)
    f === :channelType && return Ptr{CUpti_ChannelType}(x + 172)
    return getfield(x, f)
end

function Base.getproperty(x::CUpti_ActivityKernel7, f::Symbol)
    r = Ref{CUpti_ActivityKernel7}(x)
    ptr = Base.unsafe_convert(Ptr{CUpti_ActivityKernel7}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{CUpti_ActivityKernel7}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#795"
    data::NTuple{1,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#795"}, f::Symbol)
    f === :both && return Ptr{UInt8}(x + 0)
    f === :config && return Ptr{var"##Ctag#796"}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#795", f::Symbol)
    r = Ref{var"##Ctag#795"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#795"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#795"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct CUpti_ActivityKernel8
    data::NTuple{200,UInt8}
end

function Base.getproperty(x::Ptr{CUpti_ActivityKernel8}, f::Symbol)
    f === :kind && return Ptr{CUpti_ActivityKind}(x + 0)
    f === :cacheConfig && return Ptr{var"##Ctag#795"}(x + 4)
    f === :sharedMemoryConfig && return Ptr{UInt8}(x + 5)
    f === :registersPerThread && return Ptr{UInt16}(x + 6)
    f === :partitionedGlobalCacheRequested &&
        return Ptr{CUpti_ActivityPartitionedGlobalCacheConfig}(x + 8)
    f === :partitionedGlobalCacheExecuted &&
        return Ptr{CUpti_ActivityPartitionedGlobalCacheConfig}(x + 12)
    f === :start && return Ptr{UInt64}(x + 16)
    f === :_end && return Ptr{UInt64}(x + 24)
    f === :completed && return Ptr{UInt64}(x + 32)
    f === :deviceId && return Ptr{UInt32}(x + 40)
    f === :contextId && return Ptr{UInt32}(x + 44)
    f === :streamId && return Ptr{UInt32}(x + 48)
    f === :gridX && return Ptr{Int32}(x + 52)
    f === :gridY && return Ptr{Int32}(x + 56)
    f === :gridZ && return Ptr{Int32}(x + 60)
    f === :blockX && return Ptr{Int32}(x + 64)
    f === :blockY && return Ptr{Int32}(x + 68)
    f === :blockZ && return Ptr{Int32}(x + 72)
    f === :staticSharedMemory && return Ptr{Int32}(x + 76)
    f === :dynamicSharedMemory && return Ptr{Int32}(x + 80)
    f === :localMemoryPerThread && return Ptr{UInt32}(x + 84)
    f === :localMemoryTotal && return Ptr{UInt32}(x + 88)
    f === :correlationId && return Ptr{UInt32}(x + 92)
    f === :gridId && return Ptr{Int64}(x + 96)
    f === :name && return Ptr{Cstring}(x + 104)
    f === :reserved0 && return Ptr{Ptr{Cvoid}}(x + 112)
    f === :queued && return Ptr{UInt64}(x + 120)
    f === :submitted && return Ptr{UInt64}(x + 128)
    f === :launchType && return Ptr{UInt8}(x + 136)
    f === :isSharedMemoryCarveoutRequested && return Ptr{UInt8}(x + 137)
    f === :sharedMemoryCarveoutRequested && return Ptr{UInt8}(x + 138)
    f === :padding && return Ptr{UInt8}(x + 139)
    f === :sharedMemoryExecuted && return Ptr{UInt32}(x + 140)
    f === :graphNodeId && return Ptr{UInt64}(x + 144)
    f === :shmemLimitConfig && return Ptr{CUpti_FuncShmemLimitConfig}(x + 152)
    f === :graphId && return Ptr{UInt32}(x + 156)
    f === :pAccessPolicyWindow && return Ptr{Ptr{CUaccessPolicyWindow}}(x + 160)
    f === :channelID && return Ptr{UInt32}(x + 168)
    f === :channelType && return Ptr{CUpti_ChannelType}(x + 172)
    f === :clusterX && return Ptr{UInt32}(x + 176)
    f === :clusterY && return Ptr{UInt32}(x + 180)
    f === :clusterZ && return Ptr{UInt32}(x + 184)
    f === :clusterSchedulingPolicy && return Ptr{UInt32}(x + 188)
    f === :localMemoryTotal_v2 && return Ptr{UInt64}(x + 192)
    return getfield(x, f)
end

function Base.getproperty(x::CUpti_ActivityKernel8, f::Symbol)
    r = Ref{CUpti_ActivityKernel8}(x)
    ptr = Base.unsafe_convert(Ptr{CUpti_ActivityKernel8}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{CUpti_ActivityKernel8}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#733"
    data::NTuple{1,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#733"}, f::Symbol)
    f === :both && return Ptr{UInt8}(x + 0)
    f === :config && return Ptr{var"##Ctag#734"}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#733", f::Symbol)
    r = Ref{var"##Ctag#733"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#733"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#733"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct CUpti_ActivityCdpKernel
    data::NTuple{144,UInt8}
end

function Base.getproperty(x::Ptr{CUpti_ActivityCdpKernel}, f::Symbol)
    f === :kind && return Ptr{CUpti_ActivityKind}(x + 0)
    f === :cacheConfig && return Ptr{var"##Ctag#733"}(x + 4)
    f === :sharedMemoryConfig && return Ptr{UInt8}(x + 5)
    f === :registersPerThread && return Ptr{UInt16}(x + 6)
    f === :start && return Ptr{UInt64}(x + 8)
    f === :_end && return Ptr{UInt64}(x + 16)
    f === :deviceId && return Ptr{UInt32}(x + 24)
    f === :contextId && return Ptr{UInt32}(x + 28)
    f === :streamId && return Ptr{UInt32}(x + 32)
    f === :gridX && return Ptr{Int32}(x + 36)
    f === :gridY && return Ptr{Int32}(x + 40)
    f === :gridZ && return Ptr{Int32}(x + 44)
    f === :blockX && return Ptr{Int32}(x + 48)
    f === :blockY && return Ptr{Int32}(x + 52)
    f === :blockZ && return Ptr{Int32}(x + 56)
    f === :staticSharedMemory && return Ptr{Int32}(x + 60)
    f === :dynamicSharedMemory && return Ptr{Int32}(x + 64)
    f === :localMemoryPerThread && return Ptr{UInt32}(x + 68)
    f === :localMemoryTotal && return Ptr{UInt32}(x + 72)
    f === :correlationId && return Ptr{UInt32}(x + 76)
    f === :gridId && return Ptr{Int64}(x + 80)
    f === :parentGridId && return Ptr{Int64}(x + 88)
    f === :queued && return Ptr{UInt64}(x + 96)
    f === :submitted && return Ptr{UInt64}(x + 104)
    f === :completed && return Ptr{UInt64}(x + 112)
    f === :parentBlockX && return Ptr{UInt32}(x + 120)
    f === :parentBlockY && return Ptr{UInt32}(x + 124)
    f === :parentBlockZ && return Ptr{UInt32}(x + 128)
    f === :pad && return Ptr{UInt32}(x + 132)
    f === :name && return Ptr{Cstring}(x + 136)
    return getfield(x, f)
end

function Base.getproperty(x::CUpti_ActivityCdpKernel, f::Symbol)
    r = Ref{CUpti_ActivityCdpKernel}(x)
    ptr = Base.unsafe_convert(Ptr{CUpti_ActivityCdpKernel}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{CUpti_ActivityCdpKernel}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct CUpti_ActivityPreemption
    kind::CUpti_ActivityKind
    preemptionKind::CUpti_ActivityPreemptionKind
    timestamp::UInt64
    gridId::Int64
    blockX::UInt32
    blockY::UInt32
    blockZ::UInt32
    pad::UInt32
end

struct CUpti_ActivityAPI
    kind::CUpti_ActivityKind
    cbid::CUpti_CallbackId
    start::UInt64
    _end::UInt64
    processId::UInt32
    threadId::UInt32
    correlationId::UInt32
    returnValue::UInt32
end

struct CUpti_ActivityEvent
    kind::CUpti_ActivityKind
    id::CUpti_EventID
    value::UInt64
    domain::CUpti_EventDomainID
    correlationId::UInt32
end

struct CUpti_ActivityEventInstance
    kind::CUpti_ActivityKind
    id::CUpti_EventID
    domain::CUpti_EventDomainID
    instance::UInt32
    value::UInt64
    correlationId::UInt32
    pad::UInt32
end

struct CUpti_ActivityMetric
    kind::CUpti_ActivityKind
    id::CUpti_MetricID
    value::CUpti_MetricValue
    correlationId::UInt32
    flags::UInt8
    pad::NTuple{3,UInt8}
end

struct CUpti_ActivityMetricInstance
    kind::CUpti_ActivityKind
    id::CUpti_MetricID
    value::CUpti_MetricValue
    instance::UInt32
    correlationId::UInt32
    flags::UInt8
    pad::NTuple{7,UInt8}
end

struct CUpti_ActivitySourceLocator
    kind::CUpti_ActivityKind
    id::UInt32
    lineNumber::UInt32
    pad::UInt32
    fileName::Cstring
end

struct CUpti_ActivityGlobalAccess
    kind::CUpti_ActivityKind
    flags::CUpti_ActivityFlag
    sourceLocatorId::UInt32
    correlationId::UInt32
    pcOffset::UInt32
    executed::UInt32
    threadsExecuted::UInt64
    l2_transactions::UInt64
end

struct CUpti_ActivityGlobalAccess2
    kind::CUpti_ActivityKind
    flags::CUpti_ActivityFlag
    sourceLocatorId::UInt32
    correlationId::UInt32
    functionId::UInt32
    pcOffset::UInt32
    threadsExecuted::UInt64
    l2_transactions::UInt64
    theoreticalL2Transactions::UInt64
    executed::UInt32
    pad::UInt32
end

struct CUpti_ActivityGlobalAccess3
    kind::CUpti_ActivityKind
    flags::CUpti_ActivityFlag
    sourceLocatorId::UInt32
    correlationId::UInt32
    functionId::UInt32
    executed::UInt32
    pcOffset::UInt64
    threadsExecuted::UInt64
    l2_transactions::UInt64
    theoreticalL2Transactions::UInt64
end

struct CUpti_ActivityBranch
    kind::CUpti_ActivityKind
    sourceLocatorId::UInt32
    correlationId::UInt32
    pcOffset::UInt32
    executed::UInt32
    diverged::UInt32
    threadsExecuted::UInt64
end

struct CUpti_ActivityBranch2
    kind::CUpti_ActivityKind
    sourceLocatorId::UInt32
    correlationId::UInt32
    functionId::UInt32
    pcOffset::UInt32
    diverged::UInt32
    threadsExecuted::UInt64
    executed::UInt32
    pad::UInt32
end

struct CUpti_ActivityDevice
    kind::CUpti_ActivityKind
    flags::CUpti_ActivityFlag
    globalMemoryBandwidth::UInt64
    globalMemorySize::UInt64
    constantMemorySize::UInt32
    l2CacheSize::UInt32
    numThreadsPerWarp::UInt32
    coreClockRate::UInt32
    numMemcpyEngines::UInt32
    numMultiprocessors::UInt32
    maxIPC::UInt32
    maxWarpsPerMultiprocessor::UInt32
    maxBlocksPerMultiprocessor::UInt32
    maxRegistersPerBlock::UInt32
    maxSharedMemoryPerBlock::UInt32
    maxThreadsPerBlock::UInt32
    maxBlockDimX::UInt32
    maxBlockDimY::UInt32
    maxBlockDimZ::UInt32
    maxGridDimX::UInt32
    maxGridDimY::UInt32
    maxGridDimZ::UInt32
    computeCapabilityMajor::UInt32
    computeCapabilityMinor::UInt32
    id::UInt32
    pad::UInt32
    name::Cstring
end

struct CUpti_ActivityDevice2
    kind::CUpti_ActivityKind
    flags::CUpti_ActivityFlag
    globalMemoryBandwidth::UInt64
    globalMemorySize::UInt64
    constantMemorySize::UInt32
    l2CacheSize::UInt32
    numThreadsPerWarp::UInt32
    coreClockRate::UInt32
    numMemcpyEngines::UInt32
    numMultiprocessors::UInt32
    maxIPC::UInt32
    maxWarpsPerMultiprocessor::UInt32
    maxBlocksPerMultiprocessor::UInt32
    maxSharedMemoryPerMultiprocessor::UInt32
    maxRegistersPerMultiprocessor::UInt32
    maxRegistersPerBlock::UInt32
    maxSharedMemoryPerBlock::UInt32
    maxThreadsPerBlock::UInt32
    maxBlockDimX::UInt32
    maxBlockDimY::UInt32
    maxBlockDimZ::UInt32
    maxGridDimX::UInt32
    maxGridDimY::UInt32
    maxGridDimZ::UInt32
    computeCapabilityMajor::UInt32
    computeCapabilityMinor::UInt32
    id::UInt32
    eccEnabled::UInt32
    uuid::CUuuid
    name::Cstring
end

struct CUpti_ActivityDevice3
    kind::CUpti_ActivityKind
    flags::CUpti_ActivityFlag
    globalMemoryBandwidth::UInt64
    globalMemorySize::UInt64
    constantMemorySize::UInt32
    l2CacheSize::UInt32
    numThreadsPerWarp::UInt32
    coreClockRate::UInt32
    numMemcpyEngines::UInt32
    numMultiprocessors::UInt32
    maxIPC::UInt32
    maxWarpsPerMultiprocessor::UInt32
    maxBlocksPerMultiprocessor::UInt32
    maxSharedMemoryPerMultiprocessor::UInt32
    maxRegistersPerMultiprocessor::UInt32
    maxRegistersPerBlock::UInt32
    maxSharedMemoryPerBlock::UInt32
    maxThreadsPerBlock::UInt32
    maxBlockDimX::UInt32
    maxBlockDimY::UInt32
    maxBlockDimZ::UInt32
    maxGridDimX::UInt32
    maxGridDimY::UInt32
    maxGridDimZ::UInt32
    computeCapabilityMajor::UInt32
    computeCapabilityMinor::UInt32
    id::UInt32
    eccEnabled::UInt32
    uuid::CUuuid
    name::Cstring
    isCudaVisible::UInt8
    reserved::NTuple{7,UInt8}
end

struct CUpti_ActivityDevice4
    kind::CUpti_ActivityKind
    flags::CUpti_ActivityFlag
    globalMemoryBandwidth::UInt64
    globalMemorySize::UInt64
    constantMemorySize::UInt32
    l2CacheSize::UInt32
    numThreadsPerWarp::UInt32
    coreClockRate::UInt32
    numMemcpyEngines::UInt32
    numMultiprocessors::UInt32
    maxIPC::UInt32
    maxWarpsPerMultiprocessor::UInt32
    maxBlocksPerMultiprocessor::UInt32
    maxSharedMemoryPerMultiprocessor::UInt32
    maxRegistersPerMultiprocessor::UInt32
    maxRegistersPerBlock::UInt32
    maxSharedMemoryPerBlock::UInt32
    maxThreadsPerBlock::UInt32
    maxBlockDimX::UInt32
    maxBlockDimY::UInt32
    maxBlockDimZ::UInt32
    maxGridDimX::UInt32
    maxGridDimY::UInt32
    maxGridDimZ::UInt32
    computeCapabilityMajor::UInt32
    computeCapabilityMinor::UInt32
    id::UInt32
    eccEnabled::UInt32
    uuid::CUuuid
    name::Cstring
    isCudaVisible::UInt8
    isMigEnabled::UInt8
    reserved::NTuple{6,UInt8}
    gpuInstanceId::UInt32
    computeInstanceId::UInt32
    migUuid::CUuuid
end

struct var"##Ctag#775"
    data::NTuple{4,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#775"}, f::Symbol)
    f === :cu && return Ptr{CUdevice_attribute}(x + 0)
    f === :cupti && return Ptr{CUpti_DeviceAttribute}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#775", f::Symbol)
    r = Ref{var"##Ctag#775"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#775"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#775"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#776"
    data::NTuple{8,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#776"}, f::Symbol)
    f === :vDouble && return Ptr{Cdouble}(x + 0)
    f === :vUint32 && return Ptr{UInt32}(x + 0)
    f === :vUint64 && return Ptr{UInt64}(x + 0)
    f === :vInt32 && return Ptr{Int32}(x + 0)
    f === :vInt64 && return Ptr{Int64}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#776", f::Symbol)
    r = Ref{var"##Ctag#776"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#776"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#776"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct CUpti_ActivityDeviceAttribute
    data::NTuple{24,UInt8}
end

function Base.getproperty(x::Ptr{CUpti_ActivityDeviceAttribute}, f::Symbol)
    f === :kind && return Ptr{CUpti_ActivityKind}(x + 0)
    f === :flags && return Ptr{CUpti_ActivityFlag}(x + 4)
    f === :deviceId && return Ptr{UInt32}(x + 8)
    f === :attribute && return Ptr{var"##Ctag#775"}(x + 12)
    f === :value && return Ptr{var"##Ctag#776"}(x + 16)
    return getfield(x, f)
end

function Base.getproperty(x::CUpti_ActivityDeviceAttribute, f::Symbol)
    r = Ref{CUpti_ActivityDeviceAttribute}(x)
    ptr = Base.unsafe_convert(Ptr{CUpti_ActivityDeviceAttribute}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{CUpti_ActivityDeviceAttribute}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct CUpti_ActivityContext
    kind::CUpti_ActivityKind
    contextId::UInt32
    deviceId::UInt32
    computeApiKind::UInt16
    nullStreamId::UInt16
end

struct CUpti_ActivityName
    kind::CUpti_ActivityKind
    objectKind::CUpti_ActivityObjectKind
    objectId::CUpti_ActivityObjectKindId
    pad::UInt32
    name::Cstring
end

struct CUpti_ActivityMarker
    kind::CUpti_ActivityKind
    flags::CUpti_ActivityFlag
    timestamp::UInt64
    id::UInt32
    objectKind::CUpti_ActivityObjectKind
    objectId::CUpti_ActivityObjectKindId
    pad::UInt32
    name::Cstring
end

struct CUpti_ActivityMarker2
    kind::CUpti_ActivityKind
    flags::CUpti_ActivityFlag
    timestamp::UInt64
    id::UInt32
    objectKind::CUpti_ActivityObjectKind
    objectId::CUpti_ActivityObjectKindId
    pad::UInt32
    name::Cstring
    domain::Cstring
end

struct CUpti_ActivityMarkerData
    kind::CUpti_ActivityKind
    flags::CUpti_ActivityFlag
    id::UInt32
    payloadKind::CUpti_MetricValueKind
    payload::CUpti_MetricValue
    color::UInt32
    category::UInt32
end

struct CUpti_ActivityOverhead
    kind::CUpti_ActivityKind
    overheadKind::CUpti_ActivityOverheadKind
    objectKind::CUpti_ActivityObjectKind
    objectId::CUpti_ActivityObjectKindId
    start::UInt64
    _end::UInt64
end

struct var"##Ctag#720"
    data::NTuple{20,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#720"}, f::Symbol)
    f === :speed && return Ptr{var"##Ctag#721"}(x + 0)
    f === :temperature && return Ptr{var"##Ctag#722"}(x + 0)
    f === :power && return Ptr{var"##Ctag#723"}(x + 0)
    f === :cooling && return Ptr{var"##Ctag#724"}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#720", f::Symbol)
    r = Ref{var"##Ctag#720"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#720"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#720"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct CUpti_ActivityEnvironment
    data::NTuple{40,UInt8}
end

function Base.getproperty(x::Ptr{CUpti_ActivityEnvironment}, f::Symbol)
    f === :kind && return Ptr{CUpti_ActivityKind}(x + 0)
    f === :deviceId && return Ptr{UInt32}(x + 4)
    f === :timestamp && return Ptr{UInt64}(x + 8)
    f === :environmentKind && return Ptr{CUpti_ActivityEnvironmentKind}(x + 16)
    f === :data && return Ptr{var"##Ctag#720"}(x + 20)
    return getfield(x, f)
end

function Base.getproperty(x::CUpti_ActivityEnvironment, f::Symbol)
    r = Ref{CUpti_ActivityEnvironment}(x)
    ptr = Base.unsafe_convert(Ptr{CUpti_ActivityEnvironment}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{CUpti_ActivityEnvironment}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct CUpti_ActivityInstructionExecution
    kind::CUpti_ActivityKind
    flags::CUpti_ActivityFlag
    sourceLocatorId::UInt32
    correlationId::UInt32
    functionId::UInt32
    pcOffset::UInt32
    threadsExecuted::UInt64
    notPredOffThreadsExecuted::UInt64
    executed::UInt32
    pad::UInt32
end

struct CUpti_ActivityPCSampling
    kind::CUpti_ActivityKind
    flags::CUpti_ActivityFlag
    sourceLocatorId::UInt32
    correlationId::UInt32
    functionId::UInt32
    pcOffset::UInt32
    samples::UInt32
    stallReason::CUpti_ActivityPCSamplingStallReason
end

struct CUpti_ActivityPCSampling2
    kind::CUpti_ActivityKind
    flags::CUpti_ActivityFlag
    sourceLocatorId::UInt32
    correlationId::UInt32
    functionId::UInt32
    pcOffset::UInt32
    latencySamples::UInt32
    samples::UInt32
    stallReason::CUpti_ActivityPCSamplingStallReason
    pad::UInt32
end

struct CUpti_ActivityPCSampling3
    kind::CUpti_ActivityKind
    flags::CUpti_ActivityFlag
    sourceLocatorId::UInt32
    correlationId::UInt32
    functionId::UInt32
    latencySamples::UInt32
    samples::UInt32
    stallReason::CUpti_ActivityPCSamplingStallReason
    pcOffset::UInt64
end

struct CUpti_ActivityPCSamplingRecordInfo
    kind::CUpti_ActivityKind
    correlationId::UInt32
    totalSamples::UInt64
    droppedSamples::UInt64
    samplingPeriodInCycles::UInt64
end

struct CUpti_ActivityUnifiedMemoryCounter
    kind::CUpti_ActivityKind
    counterKind::CUpti_ActivityUnifiedMemoryCounterKind
    scope::CUpti_ActivityUnifiedMemoryCounterScope
    deviceId::UInt32
    value::UInt64
    timestamp::UInt64
    processId::UInt32
    pad::UInt32
end

struct CUpti_ActivityUnifiedMemoryCounter2
    kind::CUpti_ActivityKind
    counterKind::CUpti_ActivityUnifiedMemoryCounterKind
    value::UInt64
    start::UInt64
    _end::UInt64
    address::UInt64
    srcId::UInt32
    dstId::UInt32
    streamId::UInt32
    processId::UInt32
    flags::UInt32
    pad::UInt32
end

struct CUpti_ActivityFunction
    kind::CUpti_ActivityKind
    id::UInt32
    contextId::UInt32
    moduleId::UInt32
    functionIndex::UInt32
    pad::UInt32
    name::Cstring
end

struct CUpti_ActivityModule
    kind::CUpti_ActivityKind
    contextId::UInt32
    id::UInt32
    cubinSize::UInt32
    cubin::Ptr{Cvoid}
end

struct CUpti_ActivitySharedAccess
    kind::CUpti_ActivityKind
    flags::CUpti_ActivityFlag
    sourceLocatorId::UInt32
    correlationId::UInt32
    functionId::UInt32
    pcOffset::UInt32
    threadsExecuted::UInt64
    sharedTransactions::UInt64
    theoreticalSharedTransactions::UInt64
    executed::UInt32
    pad::UInt32
end

struct CUpti_ActivityCudaEvent
    kind::CUpti_ActivityKind
    correlationId::UInt32
    contextId::UInt32
    streamId::UInt32
    eventId::UInt32
    pad::UInt32
end

struct CUpti_ActivityStream
    kind::CUpti_ActivityKind
    contextId::UInt32
    streamId::UInt32
    priority::UInt32
    flag::CUpti_ActivityStreamFlag
    correlationId::UInt32
end

struct CUpti_ActivitySynchronization
    kind::CUpti_ActivityKind
    type::CUpti_ActivitySynchronizationType
    start::UInt64
    _end::UInt64
    correlationId::UInt32
    contextId::UInt32
    streamId::UInt32
    cudaEventId::UInt32
end

struct CUpti_ActivityInstructionCorrelation
    kind::CUpti_ActivityKind
    flags::CUpti_ActivityFlag
    sourceLocatorId::UInt32
    functionId::UInt32
    pcOffset::UInt32
    pad::UInt32
end

@cenum CUpti_OpenAccEventKind::UInt32 begin
    CUPTI_OPENACC_EVENT_KIND_INVALID = 0
    CUPTI_OPENACC_EVENT_KIND_DEVICE_INIT = 1
    CUPTI_OPENACC_EVENT_KIND_DEVICE_SHUTDOWN = 2
    CUPTI_OPENACC_EVENT_KIND_RUNTIME_SHUTDOWN = 3
    CUPTI_OPENACC_EVENT_KIND_ENQUEUE_LAUNCH = 4
    CUPTI_OPENACC_EVENT_KIND_ENQUEUE_UPLOAD = 5
    CUPTI_OPENACC_EVENT_KIND_ENQUEUE_DOWNLOAD = 6
    CUPTI_OPENACC_EVENT_KIND_WAIT = 7
    CUPTI_OPENACC_EVENT_KIND_IMPLICIT_WAIT = 8
    CUPTI_OPENACC_EVENT_KIND_COMPUTE_CONSTRUCT = 9
    CUPTI_OPENACC_EVENT_KIND_UPDATE = 10
    CUPTI_OPENACC_EVENT_KIND_ENTER_DATA = 11
    CUPTI_OPENACC_EVENT_KIND_EXIT_DATA = 12
    CUPTI_OPENACC_EVENT_KIND_CREATE = 13
    CUPTI_OPENACC_EVENT_KIND_DELETE = 14
    CUPTI_OPENACC_EVENT_KIND_ALLOC = 15
    CUPTI_OPENACC_EVENT_KIND_FREE = 16
    CUPTI_OPENACC_EVENT_KIND_FORCE_INT = 2147483647
end

@cenum CUpti_OpenAccConstructKind::UInt32 begin
    CUPTI_OPENACC_CONSTRUCT_KIND_UNKNOWN = 0
    CUPTI_OPENACC_CONSTRUCT_KIND_PARALLEL = 1
    CUPTI_OPENACC_CONSTRUCT_KIND_KERNELS = 2
    CUPTI_OPENACC_CONSTRUCT_KIND_LOOP = 3
    CUPTI_OPENACC_CONSTRUCT_KIND_DATA = 4
    CUPTI_OPENACC_CONSTRUCT_KIND_ENTER_DATA = 5
    CUPTI_OPENACC_CONSTRUCT_KIND_EXIT_DATA = 6
    CUPTI_OPENACC_CONSTRUCT_KIND_HOST_DATA = 7
    CUPTI_OPENACC_CONSTRUCT_KIND_ATOMIC = 8
    CUPTI_OPENACC_CONSTRUCT_KIND_DECLARE = 9
    CUPTI_OPENACC_CONSTRUCT_KIND_INIT = 10
    CUPTI_OPENACC_CONSTRUCT_KIND_SHUTDOWN = 11
    CUPTI_OPENACC_CONSTRUCT_KIND_SET = 12
    CUPTI_OPENACC_CONSTRUCT_KIND_UPDATE = 13
    CUPTI_OPENACC_CONSTRUCT_KIND_ROUTINE = 14
    CUPTI_OPENACC_CONSTRUCT_KIND_WAIT = 15
    CUPTI_OPENACC_CONSTRUCT_KIND_RUNTIME_API = 16
    CUPTI_OPENACC_CONSTRUCT_KIND_FORCE_INT = 2147483647
end

@cenum CUpti_OpenMpEventKind::UInt32 begin
    CUPTI_OPENMP_EVENT_KIND_INVALID = 0
    CUPTI_OPENMP_EVENT_KIND_PARALLEL = 1
    CUPTI_OPENMP_EVENT_KIND_TASK = 2
    CUPTI_OPENMP_EVENT_KIND_THREAD = 3
    CUPTI_OPENMP_EVENT_KIND_IDLE = 4
    CUPTI_OPENMP_EVENT_KIND_WAIT_BARRIER = 5
    CUPTI_OPENMP_EVENT_KIND_WAIT_TASKWAIT = 6
    CUPTI_OPENMP_EVENT_KIND_FORCE_INT = 2147483647
end

struct CUpti_ActivityOpenAcc
    kind::CUpti_ActivityKind
    eventKind::CUpti_OpenAccEventKind
    parentConstruct::CUpti_OpenAccConstructKind
    version::UInt32
    implicit::UInt32
    deviceType::UInt32
    deviceNumber::UInt32
    threadId::UInt32
    async::UInt64
    asyncMap::UInt64
    lineNo::UInt32
    endLineNo::UInt32
    funcLineNo::UInt32
    funcEndLineNo::UInt32
    start::UInt64
    _end::UInt64
    cuDeviceId::UInt32
    cuContextId::UInt32
    cuStreamId::UInt32
    cuProcessId::UInt32
    cuThreadId::UInt32
    externalId::UInt32
    srcFile::Cstring
    funcName::Cstring
end

struct CUpti_ActivityOpenAccData
    kind::CUpti_ActivityKind
    eventKind::CUpti_OpenAccEventKind
    parentConstruct::CUpti_OpenAccConstructKind
    version::UInt32
    implicit::UInt32
    deviceType::UInt32
    deviceNumber::UInt32
    threadId::UInt32
    async::UInt64
    asyncMap::UInt64
    lineNo::UInt32
    endLineNo::UInt32
    funcLineNo::UInt32
    funcEndLineNo::UInt32
    start::UInt64
    _end::UInt64
    cuDeviceId::UInt32
    cuContextId::UInt32
    cuStreamId::UInt32
    cuProcessId::UInt32
    cuThreadId::UInt32
    externalId::UInt32
    srcFile::Cstring
    funcName::Cstring
    bytes::UInt64
    hostPtr::UInt64
    devicePtr::UInt64
    varName::Cstring
end

struct CUpti_ActivityOpenAccLaunch
    kind::CUpti_ActivityKind
    eventKind::CUpti_OpenAccEventKind
    parentConstruct::CUpti_OpenAccConstructKind
    version::UInt32
    implicit::UInt32
    deviceType::UInt32
    deviceNumber::UInt32
    threadId::UInt32
    async::UInt64
    asyncMap::UInt64
    lineNo::UInt32
    endLineNo::UInt32
    funcLineNo::UInt32
    funcEndLineNo::UInt32
    start::UInt64
    _end::UInt64
    cuDeviceId::UInt32
    cuContextId::UInt32
    cuStreamId::UInt32
    cuProcessId::UInt32
    cuThreadId::UInt32
    externalId::UInt32
    srcFile::Cstring
    funcName::Cstring
    numGangs::UInt64
    numWorkers::UInt64
    vectorLength::UInt64
    kernelName::Cstring
end

struct CUpti_ActivityOpenAccOther
    kind::CUpti_ActivityKind
    eventKind::CUpti_OpenAccEventKind
    parentConstruct::CUpti_OpenAccConstructKind
    version::UInt32
    implicit::UInt32
    deviceType::UInt32
    deviceNumber::UInt32
    threadId::UInt32
    async::UInt64
    asyncMap::UInt64
    lineNo::UInt32
    endLineNo::UInt32
    funcLineNo::UInt32
    funcEndLineNo::UInt32
    start::UInt64
    _end::UInt64
    cuDeviceId::UInt32
    cuContextId::UInt32
    cuStreamId::UInt32
    cuProcessId::UInt32
    cuThreadId::UInt32
    externalId::UInt32
    srcFile::Cstring
    funcName::Cstring
end

struct CUpti_ActivityOpenMp
    kind::CUpti_ActivityKind
    eventKind::CUpti_OpenMpEventKind
    version::UInt32
    threadId::UInt32
    start::UInt64
    _end::UInt64
    cuProcessId::UInt32
    cuThreadId::UInt32
end

@cenum CUpti_ExternalCorrelationKind::UInt32 begin
    CUPTI_EXTERNAL_CORRELATION_KIND_INVALID = 0
    CUPTI_EXTERNAL_CORRELATION_KIND_UNKNOWN = 1
    CUPTI_EXTERNAL_CORRELATION_KIND_OPENACC = 2
    CUPTI_EXTERNAL_CORRELATION_KIND_CUSTOM0 = 3
    CUPTI_EXTERNAL_CORRELATION_KIND_CUSTOM1 = 4
    CUPTI_EXTERNAL_CORRELATION_KIND_CUSTOM2 = 5
    CUPTI_EXTERNAL_CORRELATION_KIND_SIZE = 6
    CUPTI_EXTERNAL_CORRELATION_KIND_FORCE_INT = 2147483647
end

struct CUpti_ActivityExternalCorrelation
    kind::CUpti_ActivityKind
    externalKind::CUpti_ExternalCorrelationKind
    externalId::UInt64
    correlationId::UInt32
    reserved::UInt32
end

@cenum CUpti_DevType::UInt32 begin
    CUPTI_DEV_TYPE_INVALID = 0
    CUPTI_DEV_TYPE_GPU = 1
    CUPTI_DEV_TYPE_NPU = 2
    CUPTI_DEV_TYPE_FORCE_INT = 2147483647
end

struct var"##Ctag#729"
    data::NTuple{16,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#729"}, f::Symbol)
    f === :uuidDev && return Ptr{CUuuid}(x + 0)
    f === :npu && return Ptr{var"##Ctag#730"}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#729", f::Symbol)
    r = Ref{var"##Ctag#729"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#729"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#729"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#731"
    data::NTuple{16,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#731"}, f::Symbol)
    f === :uuidDev && return Ptr{CUuuid}(x + 0)
    f === :npu && return Ptr{var"##Ctag#732"}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#731", f::Symbol)
    r = Ref{var"##Ctag#731"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#731"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#731"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct CUpti_ActivityNvLink
    data::NTuple{72,UInt8}
end

function Base.getproperty(x::Ptr{CUpti_ActivityNvLink}, f::Symbol)
    f === :kind && return Ptr{CUpti_ActivityKind}(x + 0)
    f === :nvlinkVersion && return Ptr{UInt32}(x + 4)
    f === :typeDev0 && return Ptr{CUpti_DevType}(x + 8)
    f === :typeDev1 && return Ptr{CUpti_DevType}(x + 12)
    f === :idDev0 && return Ptr{var"##Ctag#729"}(x + 16)
    f === :idDev1 && return Ptr{var"##Ctag#731"}(x + 32)
    f === :flag && return Ptr{UInt32}(x + 48)
    f === :physicalNvLinkCount && return Ptr{UInt32}(x + 52)
    f === :portDev0 && return Ptr{NTuple{4,Int8}}(x + 56)
    f === :portDev1 && return Ptr{NTuple{4,Int8}}(x + 60)
    f === :bandwidth && return Ptr{UInt64}(x + 64)
    return getfield(x, f)
end

function Base.getproperty(x::CUpti_ActivityNvLink, f::Symbol)
    r = Ref{CUpti_ActivityNvLink}(x)
    ptr = Base.unsafe_convert(Ptr{CUpti_ActivityNvLink}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{CUpti_ActivityNvLink}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#707"
    data::NTuple{16,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#707"}, f::Symbol)
    f === :uuidDev && return Ptr{CUuuid}(x + 0)
    f === :npu && return Ptr{var"##Ctag#708"}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#707", f::Symbol)
    r = Ref{var"##Ctag#707"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#707"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#707"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#709"
    data::NTuple{16,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#709"}, f::Symbol)
    f === :uuidDev && return Ptr{CUuuid}(x + 0)
    f === :npu && return Ptr{var"##Ctag#710"}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#709", f::Symbol)
    r = Ref{var"##Ctag#709"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#709"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#709"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct CUpti_ActivityNvLink2
    data::NTuple{128,UInt8}
end

function Base.getproperty(x::Ptr{CUpti_ActivityNvLink2}, f::Symbol)
    f === :kind && return Ptr{CUpti_ActivityKind}(x + 0)
    f === :nvlinkVersion && return Ptr{UInt32}(x + 4)
    f === :typeDev0 && return Ptr{CUpti_DevType}(x + 8)
    f === :typeDev1 && return Ptr{CUpti_DevType}(x + 12)
    f === :idDev0 && return Ptr{var"##Ctag#707"}(x + 16)
    f === :idDev1 && return Ptr{var"##Ctag#709"}(x + 32)
    f === :flag && return Ptr{UInt32}(x + 48)
    f === :physicalNvLinkCount && return Ptr{UInt32}(x + 52)
    f === :portDev0 && return Ptr{NTuple{32,Int8}}(x + 56)
    f === :portDev1 && return Ptr{NTuple{32,Int8}}(x + 88)
    f === :bandwidth && return Ptr{UInt64}(x + 120)
    return getfield(x, f)
end

function Base.getproperty(x::CUpti_ActivityNvLink2, f::Symbol)
    r = Ref{CUpti_ActivityNvLink2}(x)
    ptr = Base.unsafe_convert(Ptr{CUpti_ActivityNvLink2}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{CUpti_ActivityNvLink2}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#765"
    data::NTuple{16,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#765"}, f::Symbol)
    f === :uuidDev && return Ptr{CUuuid}(x + 0)
    f === :npu && return Ptr{var"##Ctag#766"}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#765", f::Symbol)
    r = Ref{var"##Ctag#765"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#765"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#765"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#767"
    data::NTuple{16,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#767"}, f::Symbol)
    f === :uuidDev && return Ptr{CUuuid}(x + 0)
    f === :npu && return Ptr{var"##Ctag#768"}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#767", f::Symbol)
    r = Ref{var"##Ctag#767"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#767"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#767"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct CUpti_ActivityNvLink3
    data::NTuple{136,UInt8}
end

function Base.getproperty(x::Ptr{CUpti_ActivityNvLink3}, f::Symbol)
    f === :kind && return Ptr{CUpti_ActivityKind}(x + 0)
    f === :nvlinkVersion && return Ptr{UInt32}(x + 4)
    f === :typeDev0 && return Ptr{CUpti_DevType}(x + 8)
    f === :typeDev1 && return Ptr{CUpti_DevType}(x + 12)
    f === :idDev0 && return Ptr{var"##Ctag#765"}(x + 16)
    f === :idDev1 && return Ptr{var"##Ctag#767"}(x + 32)
    f === :flag && return Ptr{UInt32}(x + 48)
    f === :physicalNvLinkCount && return Ptr{UInt32}(x + 52)
    f === :portDev0 && return Ptr{NTuple{32,Int8}}(x + 56)
    f === :portDev1 && return Ptr{NTuple{32,Int8}}(x + 88)
    f === :bandwidth && return Ptr{UInt64}(x + 120)
    f === :nvswitchConnected && return Ptr{UInt8}(x + 128)
    f === :pad && return Ptr{NTuple{7,UInt8}}(x + 129)
    return getfield(x, f)
end

function Base.getproperty(x::CUpti_ActivityNvLink3, f::Symbol)
    r = Ref{CUpti_ActivityNvLink3}(x)
    ptr = Base.unsafe_convert(Ptr{CUpti_ActivityNvLink3}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{CUpti_ActivityNvLink3}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#784"
    data::NTuple{16,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#784"}, f::Symbol)
    f === :uuidDev && return Ptr{CUuuid}(x + 0)
    f === :npu && return Ptr{var"##Ctag#785"}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#784", f::Symbol)
    r = Ref{var"##Ctag#784"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#784"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#784"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#786"
    data::NTuple{16,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#786"}, f::Symbol)
    f === :uuidDev && return Ptr{CUuuid}(x + 0)
    f === :npu && return Ptr{var"##Ctag#787"}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#786", f::Symbol)
    r = Ref{var"##Ctag#786"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#786"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#786"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct CUpti_ActivityNvLink4
    data::NTuple{136,UInt8}
end

function Base.getproperty(x::Ptr{CUpti_ActivityNvLink4}, f::Symbol)
    f === :kind && return Ptr{CUpti_ActivityKind}(x + 0)
    f === :nvlinkVersion && return Ptr{UInt32}(x + 4)
    f === :typeDev0 && return Ptr{CUpti_DevType}(x + 8)
    f === :typeDev1 && return Ptr{CUpti_DevType}(x + 12)
    f === :idDev0 && return Ptr{var"##Ctag#784"}(x + 16)
    f === :idDev1 && return Ptr{var"##Ctag#786"}(x + 32)
    f === :flag && return Ptr{UInt32}(x + 48)
    f === :physicalNvLinkCount && return Ptr{UInt32}(x + 52)
    f === :portDev0 && return Ptr{NTuple{32,Int8}}(x + 56)
    f === :portDev1 && return Ptr{NTuple{32,Int8}}(x + 88)
    f === :bandwidth && return Ptr{UInt64}(x + 120)
    f === :nvswitchConnected && return Ptr{UInt8}(x + 128)
    f === :pad && return Ptr{NTuple{7,UInt8}}(x + 129)
    return getfield(x, f)
end

function Base.getproperty(x::CUpti_ActivityNvLink4, f::Symbol)
    r = Ref{CUpti_ActivityNvLink4}(x)
    ptr = Base.unsafe_convert(Ptr{CUpti_ActivityNvLink4}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{CUpti_ActivityNvLink4}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

@cenum CUpti_PcieDeviceType::UInt32 begin
    CUPTI_PCIE_DEVICE_TYPE_GPU = 0
    CUPTI_PCIE_DEVICE_TYPE_BRIDGE = 1
    CUPTI_PCIE_DEVICE_TYPE_FORCE_INT = 2147483647
end

struct var"##Ctag#779"
    data::NTuple{4,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#779"}, f::Symbol)
    f === :devId && return Ptr{CUdevice}(x + 0)
    f === :bridgeId && return Ptr{UInt32}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#779", f::Symbol)
    r = Ref{var"##Ctag#779"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#779"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#779"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#780"
    data::NTuple{144,UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#780"}, f::Symbol)
    f === :gpuAttr && return Ptr{var"##Ctag#781"}(x + 0)
    f === :bridgeAttr && return Ptr{var"##Ctag#782"}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#780", f::Symbol)
    r = Ref{var"##Ctag#780"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#780"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#780"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct CUpti_ActivityPcie
    data::NTuple{168,UInt8}
end

function Base.getproperty(x::Ptr{CUpti_ActivityPcie}, f::Symbol)
    f === :kind && return Ptr{CUpti_ActivityKind}(x + 0)
    f === :type && return Ptr{CUpti_PcieDeviceType}(x + 4)
    f === :id && return Ptr{var"##Ctag#779"}(x + 8)
    f === :domain && return Ptr{UInt32}(x + 12)
    f === :pcieGeneration && return Ptr{UInt16}(x + 16)
    f === :linkRate && return Ptr{UInt16}(x + 18)
    f === :linkWidth && return Ptr{UInt16}(x + 20)
    f === :upstreamBus && return Ptr{UInt16}(x + 22)
    f === :attr && return Ptr{var"##Ctag#780"}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::CUpti_ActivityPcie, f::Symbol)
    r = Ref{CUpti_ActivityPcie}(x)
    ptr = Base.unsafe_convert(Ptr{CUpti_ActivityPcie}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{CUpti_ActivityPcie}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

@cenum CUpti_PcieGen::UInt32 begin
    CUPTI_PCIE_GEN_GEN1 = 1
    CUPTI_PCIE_GEN_GEN2 = 2
    CUPTI_PCIE_GEN_GEN3 = 3
    CUPTI_PCIE_GEN_GEN4 = 4
    CUPTI_PCIE_GEN_GEN5 = 5
    CUPTI_PCIE_GEN_FORCE_INT = 2147483647
end

struct CUpti_ActivityInstantaneousEvent
    kind::CUpti_ActivityKind
    id::CUpti_EventID
    value::UInt64
    timestamp::UInt64
    deviceId::UInt32
    reserved::UInt32
end

struct CUpti_ActivityInstantaneousEventInstance
    kind::CUpti_ActivityKind
    id::CUpti_EventID
    value::UInt64
    timestamp::UInt64
    deviceId::UInt32
    instance::UInt8
    pad::NTuple{3,UInt8}
end

struct CUpti_ActivityInstantaneousMetric
    kind::CUpti_ActivityKind
    id::CUpti_MetricID
    value::CUpti_MetricValue
    timestamp::UInt64
    deviceId::UInt32
    flags::UInt8
    pad::NTuple{3,UInt8}
end

struct CUpti_ActivityInstantaneousMetricInstance
    kind::CUpti_ActivityKind
    id::CUpti_MetricID
    value::CUpti_MetricValue
    timestamp::UInt64
    deviceId::UInt32
    flags::UInt8
    instance::UInt8
    pad::NTuple{2,UInt8}
end

@cenum CUpti_ActivityJitEntryType::UInt32 begin
    CUPTI_ACTIVITY_JIT_ENTRY_INVALID = 0
    CUPTI_ACTIVITY_JIT_ENTRY_PTX_TO_CUBIN = 1
    CUPTI_ACTIVITY_JIT_ENTRY_NVVM_IR_TO_PTX = 2
    CUPTI_ACTIVITY_JIT_ENTRY_TYPE_FORCE_INT = 2147483647
end

@cenum CUpti_ActivityJitOperationType::UInt32 begin
    CUPTI_ACTIVITY_JIT_OPERATION_INVALID = 0
    CUPTI_ACTIVITY_JIT_OPERATION_CACHE_LOAD = 1
    CUPTI_ACTIVITY_JIT_OPERATION_CACHE_STORE = 2
    CUPTI_ACTIVITY_JIT_OPERATION_COMPILE = 3
    CUPTI_ACTIVITY_JIT_OPERATION_TYPE_FORCE_INT = 2147483647
end

struct CUpti_ActivityJit
    kind::CUpti_ActivityKind
    jitEntryType::CUpti_ActivityJitEntryType
    jitOperationType::CUpti_ActivityJitOperationType
    deviceId::UInt32
    start::UInt64
    _end::UInt64
    correlationId::UInt32
    padding::UInt32
    jitOperationCorrelationId::UInt64
    cacheSize::UInt64
    cachePath::Cstring
end

struct CUpti_ActivityGraphTrace
    kind::CUpti_ActivityKind
    correlationId::UInt32
    start::UInt64
    _end::UInt64
    deviceId::UInt32
    graphId::UInt32
    contextId::UInt32
    streamId::UInt32
    reserved::Ptr{Cvoid}
end

@cenum CUpti_ActivityAttribute::UInt32 begin
    CUPTI_ACTIVITY_ATTR_DEVICE_BUFFER_SIZE = 0
    CUPTI_ACTIVITY_ATTR_DEVICE_BUFFER_SIZE_CDP = 1
    CUPTI_ACTIVITY_ATTR_DEVICE_BUFFER_POOL_LIMIT = 2
    CUPTI_ACTIVITY_ATTR_PROFILING_SEMAPHORE_POOL_SIZE = 3
    CUPTI_ACTIVITY_ATTR_PROFILING_SEMAPHORE_POOL_LIMIT = 4
    CUPTI_ACTIVITY_ATTR_ZEROED_OUT_ACTIVITY_BUFFER = 5
    CUPTI_ACTIVITY_ATTR_DEVICE_BUFFER_PRE_ALLOCATE_VALUE = 6
    CUPTI_ACTIVITY_ATTR_PROFILING_SEMAPHORE_PRE_ALLOCATE_VALUE = 7
    CUPTI_ACTIVITY_ATTR_MEM_ALLOCATION_TYPE_HOST_PINNED = 8
    CUPTI_ACTIVITY_ATTR_DEVICE_BUFFER_FORCE_INT = 2147483647
end

@cenum CUpti_ActivityThreadIdType::UInt32 begin
    CUPTI_ACTIVITY_THREAD_ID_TYPE_DEFAULT = 0
    CUPTI_ACTIVITY_THREAD_ID_TYPE_SYSTEM = 1
    CUPTI_ACTIVITY_THREAD_ID_TYPE_FORCE_INT = 2147483647
end

@checked function cuptiGetTimestamp(timestamp)
    initialize_context()
    @ccall libcupti.cuptiGetTimestamp(timestamp::Ptr{UInt64})::CUptiResult
end

@checked function cuptiGetContextId(context, contextId)
    initialize_context()
    @ccall libcupti.cuptiGetContextId(context::CUcontext,
                                      contextId::Ptr{UInt32})::CUptiResult
end

@checked function cuptiGetStreamId(context, stream, streamId)
    initialize_context()
    @ccall libcupti.cuptiGetStreamId(context::CUcontext, stream::CUstream,
                                     streamId::Ptr{UInt32})::CUptiResult
end

@checked function cuptiGetStreamIdEx(context, stream, perThreadStream, streamId)
    initialize_context()
    @ccall libcupti.cuptiGetStreamIdEx(context::CUcontext, stream::CUstream,
                                       perThreadStream::UInt8,
                                       streamId::Ptr{UInt32})::CUptiResult
end

@checked function cuptiGetDeviceId(context, deviceId)
    initialize_context()
    @ccall libcupti.cuptiGetDeviceId(context::CUcontext, deviceId::Ptr{UInt32})::CUptiResult
end

@checked function cuptiGetGraphNodeId(node, nodeId)
    initialize_context()
    @ccall libcupti.cuptiGetGraphNodeId(node::CUgraphNode, nodeId::Ptr{UInt64})::CUptiResult
end

@checked function cuptiGetGraphId(graph, pId)
    initialize_context()
    @ccall libcupti.cuptiGetGraphId(graph::CUgraph, pId::Ptr{UInt32})::CUptiResult
end

@checked function cuptiActivityEnable(kind)
    initialize_context()
    @ccall libcupti.cuptiActivityEnable(kind::CUpti_ActivityKind)::CUptiResult
end

@checked function cuptiActivityEnableAndDump(kind)
    initialize_context()
    @ccall libcupti.cuptiActivityEnableAndDump(kind::CUpti_ActivityKind)::CUptiResult
end

@checked function cuptiActivityDisable(kind)
    initialize_context()
    @ccall libcupti.cuptiActivityDisable(kind::CUpti_ActivityKind)::CUptiResult
end

@checked function cuptiActivityEnableContext(context, kind)
    initialize_context()
    @ccall libcupti.cuptiActivityEnableContext(context::CUcontext,
                                               kind::CUpti_ActivityKind)::CUptiResult
end

@checked function cuptiActivityDisableContext(context, kind)
    initialize_context()
    @ccall libcupti.cuptiActivityDisableContext(context::CUcontext,
                                                kind::CUpti_ActivityKind)::CUptiResult
end

@checked function cuptiActivityGetNumDroppedRecords(context, streamId, dropped)
    initialize_context()
    @ccall libcupti.cuptiActivityGetNumDroppedRecords(context::CUcontext, streamId::UInt32,
                                                      dropped::Ptr{Csize_t})::CUptiResult
end

@checked function cuptiActivityGetNextRecord(buffer, validBufferSizeBytes, record)
    initialize_context()
    @ccall libcupti.cuptiActivityGetNextRecord(buffer::Ptr{UInt8},
                                               validBufferSizeBytes::Csize_t,
                                               record::Ptr{Ptr{CUpti_Activity}})::CUptiResult
end

# typedef void ( CUPTIAPI * CUpti_BuffersCallbackRequestFunc ) ( uint8_t * * buffer , size_t * size , size_t * maxNumRecords )
const CUpti_BuffersCallbackRequestFunc = Ptr{Cvoid}

# typedef void ( CUPTIAPI * CUpti_BuffersCallbackCompleteFunc ) ( CUcontext context , uint32_t streamId , uint8_t * buffer , size_t size , size_t validSize )
const CUpti_BuffersCallbackCompleteFunc = Ptr{Cvoid}

@checked function cuptiActivityRegisterCallbacks(funcBufferRequested, funcBufferCompleted)
    initialize_context()
    @ccall libcupti.cuptiActivityRegisterCallbacks(funcBufferRequested::CUpti_BuffersCallbackRequestFunc,
                                                   funcBufferCompleted::CUpti_BuffersCallbackCompleteFunc)::CUptiResult
end

@checked function cuptiActivityFlush(context, streamId, flag)
    initialize_context()
    @ccall libcupti.cuptiActivityFlush(context::CUcontext, streamId::UInt32,
                                       flag::UInt32)::CUptiResult
end

@checked function cuptiActivityFlushAll(flag)
    initialize_context()
    @ccall libcupti.cuptiActivityFlushAll(flag::UInt32)::CUptiResult
end

@checked function cuptiActivityGetAttribute(attr, valueSize, value)
    initialize_context()
    @ccall libcupti.cuptiActivityGetAttribute(attr::CUpti_ActivityAttribute,
                                              valueSize::Ptr{Csize_t},
                                              value::Ptr{Cvoid})::CUptiResult
end

@checked function cuptiActivitySetAttribute(attr, valueSize, value)
    initialize_context()
    @ccall libcupti.cuptiActivitySetAttribute(attr::CUpti_ActivityAttribute,
                                              valueSize::Ptr{Csize_t},
                                              value::Ptr{Cvoid})::CUptiResult
end

@checked function cuptiActivityConfigureUnifiedMemoryCounter(config, count)
    initialize_context()
    @ccall libcupti.cuptiActivityConfigureUnifiedMemoryCounter(config::Ptr{CUpti_ActivityUnifiedMemoryCounterConfig},
                                                               count::UInt32)::CUptiResult
end

@checked function cuptiGetAutoBoostState(context, state)
    initialize_context()
    @ccall libcupti.cuptiGetAutoBoostState(context::CUcontext,
                                           state::Ptr{CUpti_ActivityAutoBoostState})::CUptiResult
end

@checked function cuptiActivityConfigurePCSampling(ctx, config)
    initialize_context()
    @ccall libcupti.cuptiActivityConfigurePCSampling(ctx::CUcontext,
                                                     config::Ptr{CUpti_ActivityPCSamplingConfig})::CUptiResult
end

@checked function cuptiGetLastError()
    initialize_context()
    @ccall libcupti.cuptiGetLastError()::CUptiResult
end

@checked function cuptiSetThreadIdType(type)
    initialize_context()
    @ccall libcupti.cuptiSetThreadIdType(type::CUpti_ActivityThreadIdType)::CUptiResult
end

@checked function cuptiGetThreadIdType(type)
    initialize_context()
    @ccall libcupti.cuptiGetThreadIdType(type::Ptr{CUpti_ActivityThreadIdType})::CUptiResult
end

@checked function cuptiComputeCapabilitySupported(major, minor, support)
    initialize_context()
    @ccall libcupti.cuptiComputeCapabilitySupported(major::Cint, minor::Cint,
                                                    support::Ptr{Cint})::CUptiResult
end

@checked function cuptiDeviceSupported(dev, support)
    initialize_context()
    @ccall libcupti.cuptiDeviceSupported(dev::CUdevice, support::Ptr{Cint})::CUptiResult
end

@cenum CUpti_DeviceVirtualizationMode::UInt32 begin
    CUPTI_DEVICE_VIRTUALIZATION_MODE_NONE = 0
    CUPTI_DEVICE_VIRTUALIZATION_MODE_PASS_THROUGH = 1
    CUPTI_DEVICE_VIRTUALIZATION_MODE_VIRTUAL_GPU = 2
    CUPTI_DEVICE_VIRTUALIZATION_MODE_FORCE_INT = 2147483647
end

@checked function cuptiDeviceVirtualizationMode(dev, mode)
    initialize_context()
    @ccall libcupti.cuptiDeviceVirtualizationMode(dev::CUdevice,
                                                  mode::Ptr{CUpti_DeviceVirtualizationMode})::CUptiResult
end

@checked function cuptiFinalize()
    initialize_context()
    @ccall libcupti.cuptiFinalize()::CUptiResult
end

@checked function cuptiActivityPushExternalCorrelationId(kind, id)
    initialize_context()
    @ccall libcupti.cuptiActivityPushExternalCorrelationId(kind::CUpti_ExternalCorrelationKind,
                                                           id::UInt64)::CUptiResult
end

@checked function cuptiActivityPopExternalCorrelationId(kind, lastId)
    initialize_context()
    @ccall libcupti.cuptiActivityPopExternalCorrelationId(kind::CUpti_ExternalCorrelationKind,
                                                          lastId::Ptr{UInt64})::CUptiResult
end

@checked function cuptiActivityEnableLatencyTimestamps(enable)
    initialize_context()
    @ccall libcupti.cuptiActivityEnableLatencyTimestamps(enable::UInt8)::CUptiResult
end

@checked function cuptiActivityFlushPeriod(time)
    initialize_context()
    @ccall libcupti.cuptiActivityFlushPeriod(time::UInt32)::CUptiResult
end

@checked function cuptiActivityEnableLaunchAttributes(enable)
    initialize_context()
    @ccall libcupti.cuptiActivityEnableLaunchAttributes(enable::UInt8)::CUptiResult
end

# typedef uint64_t ( CUPTIAPI * CUpti_TimestampCallbackFunc ) ( void )
const CUpti_TimestampCallbackFunc = Ptr{Cvoid}

@checked function cuptiActivityRegisterTimestampCallback(funcTimestamp)
    initialize_context()
    @ccall libcupti.cuptiActivityRegisterTimestampCallback(funcTimestamp::CUpti_TimestampCallbackFunc)::CUptiResult
end

@cenum CUpti_driver_api_trace_cbid_enum::UInt32 begin
    CUPTI_DRIVER_TRACE_CBID_INVALID = 0
    CUPTI_DRIVER_TRACE_CBID_cuInit = 1
    CUPTI_DRIVER_TRACE_CBID_cuDriverGetVersion = 2
    CUPTI_DRIVER_TRACE_CBID_cuDeviceGet = 3
    CUPTI_DRIVER_TRACE_CBID_cuDeviceGetCount = 4
    CUPTI_DRIVER_TRACE_CBID_cuDeviceGetName = 5
    CUPTI_DRIVER_TRACE_CBID_cuDeviceComputeCapability = 6
    CUPTI_DRIVER_TRACE_CBID_cuDeviceTotalMem = 7
    CUPTI_DRIVER_TRACE_CBID_cuDeviceGetProperties = 8
    CUPTI_DRIVER_TRACE_CBID_cuDeviceGetAttribute = 9
    CUPTI_DRIVER_TRACE_CBID_cuCtxCreate = 10
    CUPTI_DRIVER_TRACE_CBID_cuCtxDestroy = 11
    CUPTI_DRIVER_TRACE_CBID_cuCtxAttach = 12
    CUPTI_DRIVER_TRACE_CBID_cuCtxDetach = 13
    CUPTI_DRIVER_TRACE_CBID_cuCtxPushCurrent = 14
    CUPTI_DRIVER_TRACE_CBID_cuCtxPopCurrent = 15
    CUPTI_DRIVER_TRACE_CBID_cuCtxGetDevice = 16
    CUPTI_DRIVER_TRACE_CBID_cuCtxSynchronize = 17
    CUPTI_DRIVER_TRACE_CBID_cuModuleLoad = 18
    CUPTI_DRIVER_TRACE_CBID_cuModuleLoadData = 19
    CUPTI_DRIVER_TRACE_CBID_cuModuleLoadDataEx = 20
    CUPTI_DRIVER_TRACE_CBID_cuModuleLoadFatBinary = 21
    CUPTI_DRIVER_TRACE_CBID_cuModuleUnload = 22
    CUPTI_DRIVER_TRACE_CBID_cuModuleGetFunction = 23
    CUPTI_DRIVER_TRACE_CBID_cuModuleGetGlobal = 24
    CUPTI_DRIVER_TRACE_CBID_cu64ModuleGetGlobal = 25
    CUPTI_DRIVER_TRACE_CBID_cuModuleGetTexRef = 26
    CUPTI_DRIVER_TRACE_CBID_cuMemGetInfo = 27
    CUPTI_DRIVER_TRACE_CBID_cu64MemGetInfo = 28
    CUPTI_DRIVER_TRACE_CBID_cuMemAlloc = 29
    CUPTI_DRIVER_TRACE_CBID_cu64MemAlloc = 30
    CUPTI_DRIVER_TRACE_CBID_cuMemAllocPitch = 31
    CUPTI_DRIVER_TRACE_CBID_cu64MemAllocPitch = 32
    CUPTI_DRIVER_TRACE_CBID_cuMemFree = 33
    CUPTI_DRIVER_TRACE_CBID_cu64MemFree = 34
    CUPTI_DRIVER_TRACE_CBID_cuMemGetAddressRange = 35
    CUPTI_DRIVER_TRACE_CBID_cu64MemGetAddressRange = 36
    CUPTI_DRIVER_TRACE_CBID_cuMemAllocHost = 37
    CUPTI_DRIVER_TRACE_CBID_cuMemFreeHost = 38
    CUPTI_DRIVER_TRACE_CBID_cuMemHostAlloc = 39
    CUPTI_DRIVER_TRACE_CBID_cuMemHostGetDevicePointer = 40
    CUPTI_DRIVER_TRACE_CBID_cu64MemHostGetDevicePointer = 41
    CUPTI_DRIVER_TRACE_CBID_cuMemHostGetFlags = 42
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyHtoD = 43
    CUPTI_DRIVER_TRACE_CBID_cu64MemcpyHtoD = 44
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyDtoH = 45
    CUPTI_DRIVER_TRACE_CBID_cu64MemcpyDtoH = 46
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyDtoD = 47
    CUPTI_DRIVER_TRACE_CBID_cu64MemcpyDtoD = 48
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyDtoA = 49
    CUPTI_DRIVER_TRACE_CBID_cu64MemcpyDtoA = 50
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyAtoD = 51
    CUPTI_DRIVER_TRACE_CBID_cu64MemcpyAtoD = 52
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyHtoA = 53
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyAtoH = 54
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyAtoA = 55
    CUPTI_DRIVER_TRACE_CBID_cuMemcpy2D = 56
    CUPTI_DRIVER_TRACE_CBID_cuMemcpy2DUnaligned = 57
    CUPTI_DRIVER_TRACE_CBID_cuMemcpy3D = 58
    CUPTI_DRIVER_TRACE_CBID_cu64Memcpy3D = 59
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyHtoDAsync = 60
    CUPTI_DRIVER_TRACE_CBID_cu64MemcpyHtoDAsync = 61
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyDtoHAsync = 62
    CUPTI_DRIVER_TRACE_CBID_cu64MemcpyDtoHAsync = 63
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyDtoDAsync = 64
    CUPTI_DRIVER_TRACE_CBID_cu64MemcpyDtoDAsync = 65
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyHtoAAsync = 66
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyAtoHAsync = 67
    CUPTI_DRIVER_TRACE_CBID_cuMemcpy2DAsync = 68
    CUPTI_DRIVER_TRACE_CBID_cuMemcpy3DAsync = 69
    CUPTI_DRIVER_TRACE_CBID_cu64Memcpy3DAsync = 70
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD8 = 71
    CUPTI_DRIVER_TRACE_CBID_cu64MemsetD8 = 72
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD16 = 73
    CUPTI_DRIVER_TRACE_CBID_cu64MemsetD16 = 74
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD32 = 75
    CUPTI_DRIVER_TRACE_CBID_cu64MemsetD32 = 76
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD2D8 = 77
    CUPTI_DRIVER_TRACE_CBID_cu64MemsetD2D8 = 78
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD2D16 = 79
    CUPTI_DRIVER_TRACE_CBID_cu64MemsetD2D16 = 80
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD2D32 = 81
    CUPTI_DRIVER_TRACE_CBID_cu64MemsetD2D32 = 82
    CUPTI_DRIVER_TRACE_CBID_cuFuncSetBlockShape = 83
    CUPTI_DRIVER_TRACE_CBID_cuFuncSetSharedSize = 84
    CUPTI_DRIVER_TRACE_CBID_cuFuncGetAttribute = 85
    CUPTI_DRIVER_TRACE_CBID_cuFuncSetCacheConfig = 86
    CUPTI_DRIVER_TRACE_CBID_cuArrayCreate = 87
    CUPTI_DRIVER_TRACE_CBID_cuArrayGetDescriptor = 88
    CUPTI_DRIVER_TRACE_CBID_cuArrayDestroy = 89
    CUPTI_DRIVER_TRACE_CBID_cuArray3DCreate = 90
    CUPTI_DRIVER_TRACE_CBID_cuArray3DGetDescriptor = 91
    CUPTI_DRIVER_TRACE_CBID_cuTexRefCreate = 92
    CUPTI_DRIVER_TRACE_CBID_cuTexRefDestroy = 93
    CUPTI_DRIVER_TRACE_CBID_cuTexRefSetArray = 94
    CUPTI_DRIVER_TRACE_CBID_cuTexRefSetAddress = 95
    CUPTI_DRIVER_TRACE_CBID_cu64TexRefSetAddress = 96
    CUPTI_DRIVER_TRACE_CBID_cuTexRefSetAddress2D = 97
    CUPTI_DRIVER_TRACE_CBID_cu64TexRefSetAddress2D = 98
    CUPTI_DRIVER_TRACE_CBID_cuTexRefSetFormat = 99
    CUPTI_DRIVER_TRACE_CBID_cuTexRefSetAddressMode = 100
    CUPTI_DRIVER_TRACE_CBID_cuTexRefSetFilterMode = 101
    CUPTI_DRIVER_TRACE_CBID_cuTexRefSetFlags = 102
    CUPTI_DRIVER_TRACE_CBID_cuTexRefGetAddress = 103
    CUPTI_DRIVER_TRACE_CBID_cu64TexRefGetAddress = 104
    CUPTI_DRIVER_TRACE_CBID_cuTexRefGetArray = 105
    CUPTI_DRIVER_TRACE_CBID_cuTexRefGetAddressMode = 106
    CUPTI_DRIVER_TRACE_CBID_cuTexRefGetFilterMode = 107
    CUPTI_DRIVER_TRACE_CBID_cuTexRefGetFormat = 108
    CUPTI_DRIVER_TRACE_CBID_cuTexRefGetFlags = 109
    CUPTI_DRIVER_TRACE_CBID_cuParamSetSize = 110
    CUPTI_DRIVER_TRACE_CBID_cuParamSeti = 111
    CUPTI_DRIVER_TRACE_CBID_cuParamSetf = 112
    CUPTI_DRIVER_TRACE_CBID_cuParamSetv = 113
    CUPTI_DRIVER_TRACE_CBID_cuParamSetTexRef = 114
    CUPTI_DRIVER_TRACE_CBID_cuLaunch = 115
    CUPTI_DRIVER_TRACE_CBID_cuLaunchGrid = 116
    CUPTI_DRIVER_TRACE_CBID_cuLaunchGridAsync = 117
    CUPTI_DRIVER_TRACE_CBID_cuEventCreate = 118
    CUPTI_DRIVER_TRACE_CBID_cuEventRecord = 119
    CUPTI_DRIVER_TRACE_CBID_cuEventQuery = 120
    CUPTI_DRIVER_TRACE_CBID_cuEventSynchronize = 121
    CUPTI_DRIVER_TRACE_CBID_cuEventDestroy = 122
    CUPTI_DRIVER_TRACE_CBID_cuEventElapsedTime = 123
    CUPTI_DRIVER_TRACE_CBID_cuStreamCreate = 124
    CUPTI_DRIVER_TRACE_CBID_cuStreamQuery = 125
    CUPTI_DRIVER_TRACE_CBID_cuStreamSynchronize = 126
    CUPTI_DRIVER_TRACE_CBID_cuStreamDestroy = 127
    CUPTI_DRIVER_TRACE_CBID_cuGraphicsUnregisterResource = 128
    CUPTI_DRIVER_TRACE_CBID_cuGraphicsSubResourceGetMappedArray = 129
    CUPTI_DRIVER_TRACE_CBID_cuGraphicsResourceGetMappedPointer = 130
    CUPTI_DRIVER_TRACE_CBID_cu64GraphicsResourceGetMappedPointer = 131
    CUPTI_DRIVER_TRACE_CBID_cuGraphicsResourceSetMapFlags = 132
    CUPTI_DRIVER_TRACE_CBID_cuGraphicsMapResources = 133
    CUPTI_DRIVER_TRACE_CBID_cuGraphicsUnmapResources = 134
    CUPTI_DRIVER_TRACE_CBID_cuGetExportTable = 135
    CUPTI_DRIVER_TRACE_CBID_cuCtxSetLimit = 136
    CUPTI_DRIVER_TRACE_CBID_cuCtxGetLimit = 137
    CUPTI_DRIVER_TRACE_CBID_cuD3D10GetDevice = 138
    CUPTI_DRIVER_TRACE_CBID_cuD3D10CtxCreate = 139
    CUPTI_DRIVER_TRACE_CBID_cuGraphicsD3D10RegisterResource = 140
    CUPTI_DRIVER_TRACE_CBID_cuD3D10RegisterResource = 141
    CUPTI_DRIVER_TRACE_CBID_cuD3D10UnregisterResource = 142
    CUPTI_DRIVER_TRACE_CBID_cuD3D10MapResources = 143
    CUPTI_DRIVER_TRACE_CBID_cuD3D10UnmapResources = 144
    CUPTI_DRIVER_TRACE_CBID_cuD3D10ResourceSetMapFlags = 145
    CUPTI_DRIVER_TRACE_CBID_cuD3D10ResourceGetMappedArray = 146
    CUPTI_DRIVER_TRACE_CBID_cuD3D10ResourceGetMappedPointer = 147
    CUPTI_DRIVER_TRACE_CBID_cuD3D10ResourceGetMappedSize = 148
    CUPTI_DRIVER_TRACE_CBID_cuD3D10ResourceGetMappedPitch = 149
    CUPTI_DRIVER_TRACE_CBID_cuD3D10ResourceGetSurfaceDimensions = 150
    CUPTI_DRIVER_TRACE_CBID_cuD3D11GetDevice = 151
    CUPTI_DRIVER_TRACE_CBID_cuD3D11CtxCreate = 152
    CUPTI_DRIVER_TRACE_CBID_cuGraphicsD3D11RegisterResource = 153
    CUPTI_DRIVER_TRACE_CBID_cuD3D9GetDevice = 154
    CUPTI_DRIVER_TRACE_CBID_cuD3D9CtxCreate = 155
    CUPTI_DRIVER_TRACE_CBID_cuGraphicsD3D9RegisterResource = 156
    CUPTI_DRIVER_TRACE_CBID_cuD3D9GetDirect3DDevice = 157
    CUPTI_DRIVER_TRACE_CBID_cuD3D9RegisterResource = 158
    CUPTI_DRIVER_TRACE_CBID_cuD3D9UnregisterResource = 159
    CUPTI_DRIVER_TRACE_CBID_cuD3D9MapResources = 160
    CUPTI_DRIVER_TRACE_CBID_cuD3D9UnmapResources = 161
    CUPTI_DRIVER_TRACE_CBID_cuD3D9ResourceSetMapFlags = 162
    CUPTI_DRIVER_TRACE_CBID_cuD3D9ResourceGetSurfaceDimensions = 163
    CUPTI_DRIVER_TRACE_CBID_cuD3D9ResourceGetMappedArray = 164
    CUPTI_DRIVER_TRACE_CBID_cuD3D9ResourceGetMappedPointer = 165
    CUPTI_DRIVER_TRACE_CBID_cuD3D9ResourceGetMappedSize = 166
    CUPTI_DRIVER_TRACE_CBID_cuD3D9ResourceGetMappedPitch = 167
    CUPTI_DRIVER_TRACE_CBID_cuD3D9Begin = 168
    CUPTI_DRIVER_TRACE_CBID_cuD3D9End = 169
    CUPTI_DRIVER_TRACE_CBID_cuD3D9RegisterVertexBuffer = 170
    CUPTI_DRIVER_TRACE_CBID_cuD3D9MapVertexBuffer = 171
    CUPTI_DRIVER_TRACE_CBID_cuD3D9UnmapVertexBuffer = 172
    CUPTI_DRIVER_TRACE_CBID_cuD3D9UnregisterVertexBuffer = 173
    CUPTI_DRIVER_TRACE_CBID_cuGLCtxCreate = 174
    CUPTI_DRIVER_TRACE_CBID_cuGraphicsGLRegisterBuffer = 175
    CUPTI_DRIVER_TRACE_CBID_cuGraphicsGLRegisterImage = 176
    CUPTI_DRIVER_TRACE_CBID_cuWGLGetDevice = 177
    CUPTI_DRIVER_TRACE_CBID_cuGLInit = 178
    CUPTI_DRIVER_TRACE_CBID_cuGLRegisterBufferObject = 179
    CUPTI_DRIVER_TRACE_CBID_cuGLMapBufferObject = 180
    CUPTI_DRIVER_TRACE_CBID_cuGLUnmapBufferObject = 181
    CUPTI_DRIVER_TRACE_CBID_cuGLUnregisterBufferObject = 182
    CUPTI_DRIVER_TRACE_CBID_cuGLSetBufferObjectMapFlags = 183
    CUPTI_DRIVER_TRACE_CBID_cuGLMapBufferObjectAsync = 184
    CUPTI_DRIVER_TRACE_CBID_cuGLUnmapBufferObjectAsync = 185
    CUPTI_DRIVER_TRACE_CBID_cuVDPAUGetDevice = 186
    CUPTI_DRIVER_TRACE_CBID_cuVDPAUCtxCreate = 187
    CUPTI_DRIVER_TRACE_CBID_cuGraphicsVDPAURegisterVideoSurface = 188
    CUPTI_DRIVER_TRACE_CBID_cuGraphicsVDPAURegisterOutputSurface = 189
    CUPTI_DRIVER_TRACE_CBID_cuModuleGetSurfRef = 190
    CUPTI_DRIVER_TRACE_CBID_cuSurfRefCreate = 191
    CUPTI_DRIVER_TRACE_CBID_cuSurfRefDestroy = 192
    CUPTI_DRIVER_TRACE_CBID_cuSurfRefSetFormat = 193
    CUPTI_DRIVER_TRACE_CBID_cuSurfRefSetArray = 194
    CUPTI_DRIVER_TRACE_CBID_cuSurfRefGetFormat = 195
    CUPTI_DRIVER_TRACE_CBID_cuSurfRefGetArray = 196
    CUPTI_DRIVER_TRACE_CBID_cu64DeviceTotalMem = 197
    CUPTI_DRIVER_TRACE_CBID_cu64D3D10ResourceGetMappedPointer = 198
    CUPTI_DRIVER_TRACE_CBID_cu64D3D10ResourceGetMappedSize = 199
    CUPTI_DRIVER_TRACE_CBID_cu64D3D10ResourceGetMappedPitch = 200
    CUPTI_DRIVER_TRACE_CBID_cu64D3D10ResourceGetSurfaceDimensions = 201
    CUPTI_DRIVER_TRACE_CBID_cu64D3D9ResourceGetSurfaceDimensions = 202
    CUPTI_DRIVER_TRACE_CBID_cu64D3D9ResourceGetMappedPointer = 203
    CUPTI_DRIVER_TRACE_CBID_cu64D3D9ResourceGetMappedSize = 204
    CUPTI_DRIVER_TRACE_CBID_cu64D3D9ResourceGetMappedPitch = 205
    CUPTI_DRIVER_TRACE_CBID_cu64D3D9MapVertexBuffer = 206
    CUPTI_DRIVER_TRACE_CBID_cu64GLMapBufferObject = 207
    CUPTI_DRIVER_TRACE_CBID_cu64GLMapBufferObjectAsync = 208
    CUPTI_DRIVER_TRACE_CBID_cuD3D11GetDevices = 209
    CUPTI_DRIVER_TRACE_CBID_cuD3D11CtxCreateOnDevice = 210
    CUPTI_DRIVER_TRACE_CBID_cuD3D10GetDevices = 211
    CUPTI_DRIVER_TRACE_CBID_cuD3D10CtxCreateOnDevice = 212
    CUPTI_DRIVER_TRACE_CBID_cuD3D9GetDevices = 213
    CUPTI_DRIVER_TRACE_CBID_cuD3D9CtxCreateOnDevice = 214
    CUPTI_DRIVER_TRACE_CBID_cu64MemHostAlloc = 215
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD8Async = 216
    CUPTI_DRIVER_TRACE_CBID_cu64MemsetD8Async = 217
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD16Async = 218
    CUPTI_DRIVER_TRACE_CBID_cu64MemsetD16Async = 219
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD32Async = 220
    CUPTI_DRIVER_TRACE_CBID_cu64MemsetD32Async = 221
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD2D8Async = 222
    CUPTI_DRIVER_TRACE_CBID_cu64MemsetD2D8Async = 223
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD2D16Async = 224
    CUPTI_DRIVER_TRACE_CBID_cu64MemsetD2D16Async = 225
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD2D32Async = 226
    CUPTI_DRIVER_TRACE_CBID_cu64MemsetD2D32Async = 227
    CUPTI_DRIVER_TRACE_CBID_cu64ArrayCreate = 228
    CUPTI_DRIVER_TRACE_CBID_cu64ArrayGetDescriptor = 229
    CUPTI_DRIVER_TRACE_CBID_cu64Array3DCreate = 230
    CUPTI_DRIVER_TRACE_CBID_cu64Array3DGetDescriptor = 231
    CUPTI_DRIVER_TRACE_CBID_cu64Memcpy2D = 232
    CUPTI_DRIVER_TRACE_CBID_cu64Memcpy2DUnaligned = 233
    CUPTI_DRIVER_TRACE_CBID_cu64Memcpy2DAsync = 234
    CUPTI_DRIVER_TRACE_CBID_cuCtxCreate_v2 = 235
    CUPTI_DRIVER_TRACE_CBID_cuD3D10CtxCreate_v2 = 236
    CUPTI_DRIVER_TRACE_CBID_cuD3D11CtxCreate_v2 = 237
    CUPTI_DRIVER_TRACE_CBID_cuD3D9CtxCreate_v2 = 238
    CUPTI_DRIVER_TRACE_CBID_cuGLCtxCreate_v2 = 239
    CUPTI_DRIVER_TRACE_CBID_cuVDPAUCtxCreate_v2 = 240
    CUPTI_DRIVER_TRACE_CBID_cuModuleGetGlobal_v2 = 241
    CUPTI_DRIVER_TRACE_CBID_cuMemGetInfo_v2 = 242
    CUPTI_DRIVER_TRACE_CBID_cuMemAlloc_v2 = 243
    CUPTI_DRIVER_TRACE_CBID_cuMemAllocPitch_v2 = 244
    CUPTI_DRIVER_TRACE_CBID_cuMemFree_v2 = 245
    CUPTI_DRIVER_TRACE_CBID_cuMemGetAddressRange_v2 = 246
    CUPTI_DRIVER_TRACE_CBID_cuMemHostGetDevicePointer_v2 = 247
    CUPTI_DRIVER_TRACE_CBID_cuMemcpy_v2 = 248
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD8_v2 = 249
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD16_v2 = 250
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD32_v2 = 251
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD2D8_v2 = 252
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD2D16_v2 = 253
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD2D32_v2 = 254
    CUPTI_DRIVER_TRACE_CBID_cuTexRefSetAddress_v2 = 255
    CUPTI_DRIVER_TRACE_CBID_cuTexRefSetAddress2D_v2 = 256
    CUPTI_DRIVER_TRACE_CBID_cuTexRefGetAddress_v2 = 257
    CUPTI_DRIVER_TRACE_CBID_cuGraphicsResourceGetMappedPointer_v2 = 258
    CUPTI_DRIVER_TRACE_CBID_cuDeviceTotalMem_v2 = 259
    CUPTI_DRIVER_TRACE_CBID_cuD3D10ResourceGetMappedPointer_v2 = 260
    CUPTI_DRIVER_TRACE_CBID_cuD3D10ResourceGetMappedSize_v2 = 261
    CUPTI_DRIVER_TRACE_CBID_cuD3D10ResourceGetMappedPitch_v2 = 262
    CUPTI_DRIVER_TRACE_CBID_cuD3D10ResourceGetSurfaceDimensions_v2 = 263
    CUPTI_DRIVER_TRACE_CBID_cuD3D9ResourceGetSurfaceDimensions_v2 = 264
    CUPTI_DRIVER_TRACE_CBID_cuD3D9ResourceGetMappedPointer_v2 = 265
    CUPTI_DRIVER_TRACE_CBID_cuD3D9ResourceGetMappedSize_v2 = 266
    CUPTI_DRIVER_TRACE_CBID_cuD3D9ResourceGetMappedPitch_v2 = 267
    CUPTI_DRIVER_TRACE_CBID_cuD3D9MapVertexBuffer_v2 = 268
    CUPTI_DRIVER_TRACE_CBID_cuGLMapBufferObject_v2 = 269
    CUPTI_DRIVER_TRACE_CBID_cuGLMapBufferObjectAsync_v2 = 270
    CUPTI_DRIVER_TRACE_CBID_cuMemHostAlloc_v2 = 271
    CUPTI_DRIVER_TRACE_CBID_cuArrayCreate_v2 = 272
    CUPTI_DRIVER_TRACE_CBID_cuArrayGetDescriptor_v2 = 273
    CUPTI_DRIVER_TRACE_CBID_cuArray3DCreate_v2 = 274
    CUPTI_DRIVER_TRACE_CBID_cuArray3DGetDescriptor_v2 = 275
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyHtoD_v2 = 276
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyHtoDAsync_v2 = 277
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyDtoH_v2 = 278
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyDtoHAsync_v2 = 279
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyDtoD_v2 = 280
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyDtoDAsync_v2 = 281
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyAtoH_v2 = 282
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyAtoHAsync_v2 = 283
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyAtoD_v2 = 284
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyDtoA_v2 = 285
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyAtoA_v2 = 286
    CUPTI_DRIVER_TRACE_CBID_cuMemcpy2D_v2 = 287
    CUPTI_DRIVER_TRACE_CBID_cuMemcpy2DUnaligned_v2 = 288
    CUPTI_DRIVER_TRACE_CBID_cuMemcpy2DAsync_v2 = 289
    CUPTI_DRIVER_TRACE_CBID_cuMemcpy3D_v2 = 290
    CUPTI_DRIVER_TRACE_CBID_cuMemcpy3DAsync_v2 = 291
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyHtoA_v2 = 292
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyHtoAAsync_v2 = 293
    CUPTI_DRIVER_TRACE_CBID_cuMemAllocHost_v2 = 294
    CUPTI_DRIVER_TRACE_CBID_cuStreamWaitEvent = 295
    CUPTI_DRIVER_TRACE_CBID_cuCtxGetApiVersion = 296
    CUPTI_DRIVER_TRACE_CBID_cuD3D10GetDirect3DDevice = 297
    CUPTI_DRIVER_TRACE_CBID_cuD3D11GetDirect3DDevice = 298
    CUPTI_DRIVER_TRACE_CBID_cuCtxGetCacheConfig = 299
    CUPTI_DRIVER_TRACE_CBID_cuCtxSetCacheConfig = 300
    CUPTI_DRIVER_TRACE_CBID_cuMemHostRegister = 301
    CUPTI_DRIVER_TRACE_CBID_cuMemHostUnregister = 302
    CUPTI_DRIVER_TRACE_CBID_cuCtxSetCurrent = 303
    CUPTI_DRIVER_TRACE_CBID_cuCtxGetCurrent = 304
    CUPTI_DRIVER_TRACE_CBID_cuMemcpy = 305
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyAsync = 306
    CUPTI_DRIVER_TRACE_CBID_cuLaunchKernel = 307
    CUPTI_DRIVER_TRACE_CBID_cuProfilerStart = 308
    CUPTI_DRIVER_TRACE_CBID_cuProfilerStop = 309
    CUPTI_DRIVER_TRACE_CBID_cuPointerGetAttribute = 310
    CUPTI_DRIVER_TRACE_CBID_cuProfilerInitialize = 311
    CUPTI_DRIVER_TRACE_CBID_cuDeviceCanAccessPeer = 312
    CUPTI_DRIVER_TRACE_CBID_cuCtxEnablePeerAccess = 313
    CUPTI_DRIVER_TRACE_CBID_cuCtxDisablePeerAccess = 314
    CUPTI_DRIVER_TRACE_CBID_cuMemPeerRegister = 315
    CUPTI_DRIVER_TRACE_CBID_cuMemPeerUnregister = 316
    CUPTI_DRIVER_TRACE_CBID_cuMemPeerGetDevicePointer = 317
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyPeer = 318
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyPeerAsync = 319
    CUPTI_DRIVER_TRACE_CBID_cuMemcpy3DPeer = 320
    CUPTI_DRIVER_TRACE_CBID_cuMemcpy3DPeerAsync = 321
    CUPTI_DRIVER_TRACE_CBID_cuCtxDestroy_v2 = 322
    CUPTI_DRIVER_TRACE_CBID_cuCtxPushCurrent_v2 = 323
    CUPTI_DRIVER_TRACE_CBID_cuCtxPopCurrent_v2 = 324
    CUPTI_DRIVER_TRACE_CBID_cuEventDestroy_v2 = 325
    CUPTI_DRIVER_TRACE_CBID_cuStreamDestroy_v2 = 326
    CUPTI_DRIVER_TRACE_CBID_cuTexRefSetAddress2D_v3 = 327
    CUPTI_DRIVER_TRACE_CBID_cuIpcGetMemHandle = 328
    CUPTI_DRIVER_TRACE_CBID_cuIpcOpenMemHandle = 329
    CUPTI_DRIVER_TRACE_CBID_cuIpcCloseMemHandle = 330
    CUPTI_DRIVER_TRACE_CBID_cuDeviceGetByPCIBusId = 331
    CUPTI_DRIVER_TRACE_CBID_cuDeviceGetPCIBusId = 332
    CUPTI_DRIVER_TRACE_CBID_cuGLGetDevices = 333
    CUPTI_DRIVER_TRACE_CBID_cuIpcGetEventHandle = 334
    CUPTI_DRIVER_TRACE_CBID_cuIpcOpenEventHandle = 335
    CUPTI_DRIVER_TRACE_CBID_cuCtxSetSharedMemConfig = 336
    CUPTI_DRIVER_TRACE_CBID_cuCtxGetSharedMemConfig = 337
    CUPTI_DRIVER_TRACE_CBID_cuFuncSetSharedMemConfig = 338
    CUPTI_DRIVER_TRACE_CBID_cuTexObjectCreate = 339
    CUPTI_DRIVER_TRACE_CBID_cuTexObjectDestroy = 340
    CUPTI_DRIVER_TRACE_CBID_cuTexObjectGetResourceDesc = 341
    CUPTI_DRIVER_TRACE_CBID_cuTexObjectGetTextureDesc = 342
    CUPTI_DRIVER_TRACE_CBID_cuSurfObjectCreate = 343
    CUPTI_DRIVER_TRACE_CBID_cuSurfObjectDestroy = 344
    CUPTI_DRIVER_TRACE_CBID_cuSurfObjectGetResourceDesc = 345
    CUPTI_DRIVER_TRACE_CBID_cuStreamAddCallback = 346
    CUPTI_DRIVER_TRACE_CBID_cuMipmappedArrayCreate = 347
    CUPTI_DRIVER_TRACE_CBID_cuMipmappedArrayGetLevel = 348
    CUPTI_DRIVER_TRACE_CBID_cuMipmappedArrayDestroy = 349
    CUPTI_DRIVER_TRACE_CBID_cuTexRefSetMipmappedArray = 350
    CUPTI_DRIVER_TRACE_CBID_cuTexRefSetMipmapFilterMode = 351
    CUPTI_DRIVER_TRACE_CBID_cuTexRefSetMipmapLevelBias = 352
    CUPTI_DRIVER_TRACE_CBID_cuTexRefSetMipmapLevelClamp = 353
    CUPTI_DRIVER_TRACE_CBID_cuTexRefSetMaxAnisotropy = 354
    CUPTI_DRIVER_TRACE_CBID_cuTexRefGetMipmappedArray = 355
    CUPTI_DRIVER_TRACE_CBID_cuTexRefGetMipmapFilterMode = 356
    CUPTI_DRIVER_TRACE_CBID_cuTexRefGetMipmapLevelBias = 357
    CUPTI_DRIVER_TRACE_CBID_cuTexRefGetMipmapLevelClamp = 358
    CUPTI_DRIVER_TRACE_CBID_cuTexRefGetMaxAnisotropy = 359
    CUPTI_DRIVER_TRACE_CBID_cuGraphicsResourceGetMappedMipmappedArray = 360
    CUPTI_DRIVER_TRACE_CBID_cuTexObjectGetResourceViewDesc = 361
    CUPTI_DRIVER_TRACE_CBID_cuLinkCreate = 362
    CUPTI_DRIVER_TRACE_CBID_cuLinkAddData = 363
    CUPTI_DRIVER_TRACE_CBID_cuLinkAddFile = 364
    CUPTI_DRIVER_TRACE_CBID_cuLinkComplete = 365
    CUPTI_DRIVER_TRACE_CBID_cuLinkDestroy = 366
    CUPTI_DRIVER_TRACE_CBID_cuStreamCreateWithPriority = 367
    CUPTI_DRIVER_TRACE_CBID_cuStreamGetPriority = 368
    CUPTI_DRIVER_TRACE_CBID_cuStreamGetFlags = 369
    CUPTI_DRIVER_TRACE_CBID_cuCtxGetStreamPriorityRange = 370
    CUPTI_DRIVER_TRACE_CBID_cuMemAllocManaged = 371
    CUPTI_DRIVER_TRACE_CBID_cuGetErrorString = 372
    CUPTI_DRIVER_TRACE_CBID_cuGetErrorName = 373
    CUPTI_DRIVER_TRACE_CBID_cuOccupancyMaxActiveBlocksPerMultiprocessor = 374
    CUPTI_DRIVER_TRACE_CBID_cuCompilePtx = 375
    CUPTI_DRIVER_TRACE_CBID_cuBinaryFree = 376
    CUPTI_DRIVER_TRACE_CBID_cuStreamAttachMemAsync = 377
    CUPTI_DRIVER_TRACE_CBID_cuPointerSetAttribute = 378
    CUPTI_DRIVER_TRACE_CBID_cuMemHostRegister_v2 = 379
    CUPTI_DRIVER_TRACE_CBID_cuGraphicsResourceSetMapFlags_v2 = 380
    CUPTI_DRIVER_TRACE_CBID_cuLinkCreate_v2 = 381
    CUPTI_DRIVER_TRACE_CBID_cuLinkAddData_v2 = 382
    CUPTI_DRIVER_TRACE_CBID_cuLinkAddFile_v2 = 383
    CUPTI_DRIVER_TRACE_CBID_cuOccupancyMaxPotentialBlockSize = 384
    CUPTI_DRIVER_TRACE_CBID_cuGLGetDevices_v2 = 385
    CUPTI_DRIVER_TRACE_CBID_cuDevicePrimaryCtxRetain = 386
    CUPTI_DRIVER_TRACE_CBID_cuDevicePrimaryCtxRelease = 387
    CUPTI_DRIVER_TRACE_CBID_cuDevicePrimaryCtxSetFlags = 388
    CUPTI_DRIVER_TRACE_CBID_cuDevicePrimaryCtxReset = 389
    CUPTI_DRIVER_TRACE_CBID_cuGraphicsEGLRegisterImage = 390
    CUPTI_DRIVER_TRACE_CBID_cuCtxGetFlags = 391
    CUPTI_DRIVER_TRACE_CBID_cuDevicePrimaryCtxGetState = 392
    CUPTI_DRIVER_TRACE_CBID_cuEGLStreamConsumerConnect = 393
    CUPTI_DRIVER_TRACE_CBID_cuEGLStreamConsumerDisconnect = 394
    CUPTI_DRIVER_TRACE_CBID_cuEGLStreamConsumerAcquireFrame = 395
    CUPTI_DRIVER_TRACE_CBID_cuEGLStreamConsumerReleaseFrame = 396
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyHtoD_v2_ptds = 397
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyDtoH_v2_ptds = 398
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyDtoD_v2_ptds = 399
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyDtoA_v2_ptds = 400
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyAtoD_v2_ptds = 401
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyHtoA_v2_ptds = 402
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyAtoH_v2_ptds = 403
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyAtoA_v2_ptds = 404
    CUPTI_DRIVER_TRACE_CBID_cuMemcpy2D_v2_ptds = 405
    CUPTI_DRIVER_TRACE_CBID_cuMemcpy2DUnaligned_v2_ptds = 406
    CUPTI_DRIVER_TRACE_CBID_cuMemcpy3D_v2_ptds = 407
    CUPTI_DRIVER_TRACE_CBID_cuMemcpy_ptds = 408
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyPeer_ptds = 409
    CUPTI_DRIVER_TRACE_CBID_cuMemcpy3DPeer_ptds = 410
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD8_v2_ptds = 411
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD16_v2_ptds = 412
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD32_v2_ptds = 413
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD2D8_v2_ptds = 414
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD2D16_v2_ptds = 415
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD2D32_v2_ptds = 416
    CUPTI_DRIVER_TRACE_CBID_cuGLMapBufferObject_v2_ptds = 417
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyAsync_ptsz = 418
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyHtoAAsync_v2_ptsz = 419
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyAtoHAsync_v2_ptsz = 420
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyHtoDAsync_v2_ptsz = 421
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyDtoHAsync_v2_ptsz = 422
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyDtoDAsync_v2_ptsz = 423
    CUPTI_DRIVER_TRACE_CBID_cuMemcpy2DAsync_v2_ptsz = 424
    CUPTI_DRIVER_TRACE_CBID_cuMemcpy3DAsync_v2_ptsz = 425
    CUPTI_DRIVER_TRACE_CBID_cuMemcpyPeerAsync_ptsz = 426
    CUPTI_DRIVER_TRACE_CBID_cuMemcpy3DPeerAsync_ptsz = 427
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD8Async_ptsz = 428
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD16Async_ptsz = 429
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD32Async_ptsz = 430
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD2D8Async_ptsz = 431
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD2D16Async_ptsz = 432
    CUPTI_DRIVER_TRACE_CBID_cuMemsetD2D32Async_ptsz = 433
    CUPTI_DRIVER_TRACE_CBID_cuStreamGetPriority_ptsz = 434
    CUPTI_DRIVER_TRACE_CBID_cuStreamGetFlags_ptsz = 435
    CUPTI_DRIVER_TRACE_CBID_cuStreamWaitEvent_ptsz = 436
    CUPTI_DRIVER_TRACE_CBID_cuStreamAddCallback_ptsz = 437
    CUPTI_DRIVER_TRACE_CBID_cuStreamAttachMemAsync_ptsz = 438
    CUPTI_DRIVER_TRACE_CBID_cuStreamQuery_ptsz = 439
    CUPTI_DRIVER_TRACE_CBID_cuStreamSynchronize_ptsz = 440
    CUPTI_DRIVER_TRACE_CBID_cuEventRecord_ptsz = 441
    CUPTI_DRIVER_TRACE_CBID_cuLaunchKernel_ptsz = 442
    CUPTI_DRIVER_TRACE_CBID_cuGraphicsMapResources_ptsz = 443
    CUPTI_DRIVER_TRACE_CBID_cuGraphicsUnmapResources_ptsz = 444
    CUPTI_DRIVER_TRACE_CBID_cuGLMapBufferObjectAsync_v2_ptsz = 445
    CUPTI_DRIVER_TRACE_CBID_cuEGLStreamProducerConnect = 446
    CUPTI_DRIVER_TRACE_CBID_cuEGLStreamProducerDisconnect = 447
    CUPTI_DRIVER_TRACE_CBID_cuEGLStreamProducerPresentFrame = 448
    CUPTI_DRIVER_TRACE_CBID_cuGraphicsResourceGetMappedEglFrame = 449
    CUPTI_DRIVER_TRACE_CBID_cuPointerGetAttributes = 450
    CUPTI_DRIVER_TRACE_CBID_cuOccupancyMaxActiveBlocksPerMultiprocessorWithFlags = 451
    CUPTI_DRIVER_TRACE_CBID_cuOccupancyMaxPotentialBlockSizeWithFlags = 452
    CUPTI_DRIVER_TRACE_CBID_cuEGLStreamProducerReturnFrame = 453
    CUPTI_DRIVER_TRACE_CBID_cuDeviceGetP2PAttribute = 454
    CUPTI_DRIVER_TRACE_CBID_cuTexRefSetBorderColor = 455
    CUPTI_DRIVER_TRACE_CBID_cuTexRefGetBorderColor = 456
    CUPTI_DRIVER_TRACE_CBID_cuMemAdvise = 457
    CUPTI_DRIVER_TRACE_CBID_cuStreamWaitValue32 = 458
    CUPTI_DRIVER_TRACE_CBID_cuStreamWaitValue32_ptsz = 459
    CUPTI_DRIVER_TRACE_CBID_cuStreamWriteValue32 = 460
    CUPTI_DRIVER_TRACE_CBID_cuStreamWriteValue32_ptsz = 461
    CUPTI_DRIVER_TRACE_CBID_cuStreamBatchMemOp = 462
    CUPTI_DRIVER_TRACE_CBID_cuStreamBatchMemOp_ptsz = 463
    CUPTI_DRIVER_TRACE_CBID_cuNVNbufferGetPointer = 464
    CUPTI_DRIVER_TRACE_CBID_cuNVNtextureGetArray = 465
    CUPTI_DRIVER_TRACE_CBID_cuNNSetAllocator = 466
    CUPTI_DRIVER_TRACE_CBID_cuMemPrefetchAsync = 467
    CUPTI_DRIVER_TRACE_CBID_cuMemPrefetchAsync_ptsz = 468
    CUPTI_DRIVER_TRACE_CBID_cuEventCreateFromNVNSync = 469
    CUPTI_DRIVER_TRACE_CBID_cuEGLStreamConsumerConnectWithFlags = 470
    CUPTI_DRIVER_TRACE_CBID_cuMemRangeGetAttribute = 471
    CUPTI_DRIVER_TRACE_CBID_cuMemRangeGetAttributes = 472
    CUPTI_DRIVER_TRACE_CBID_cuStreamWaitValue64 = 473
    CUPTI_DRIVER_TRACE_CBID_cuStreamWaitValue64_ptsz = 474
    CUPTI_DRIVER_TRACE_CBID_cuStreamWriteValue64 = 475
    CUPTI_DRIVER_TRACE_CBID_cuStreamWriteValue64_ptsz = 476
    CUPTI_DRIVER_TRACE_CBID_cuLaunchCooperativeKernel = 477
    CUPTI_DRIVER_TRACE_CBID_cuLaunchCooperativeKernel_ptsz = 478
    CUPTI_DRIVER_TRACE_CBID_cuEventCreateFromEGLSync = 479
    CUPTI_DRIVER_TRACE_CBID_cuLaunchCooperativeKernelMultiDevice = 480
    CUPTI_DRIVER_TRACE_CBID_cuFuncSetAttribute = 481
    CUPTI_DRIVER_TRACE_CBID_cuDeviceGetUuid = 482
    CUPTI_DRIVER_TRACE_CBID_cuStreamGetCtx = 483
    CUPTI_DRIVER_TRACE_CBID_cuStreamGetCtx_ptsz = 484
    CUPTI_DRIVER_TRACE_CBID_cuImportExternalMemory = 485
    CUPTI_DRIVER_TRACE_CBID_cuExternalMemoryGetMappedBuffer = 486
    CUPTI_DRIVER_TRACE_CBID_cuExternalMemoryGetMappedMipmappedArray = 487
    CUPTI_DRIVER_TRACE_CBID_cuDestroyExternalMemory = 488
    CUPTI_DRIVER_TRACE_CBID_cuImportExternalSemaphore = 489
    CUPTI_DRIVER_TRACE_CBID_cuSignalExternalSemaphoresAsync = 490
    CUPTI_DRIVER_TRACE_CBID_cuSignalExternalSemaphoresAsync_ptsz = 491
    CUPTI_DRIVER_TRACE_CBID_cuWaitExternalSemaphoresAsync = 492
    CUPTI_DRIVER_TRACE_CBID_cuWaitExternalSemaphoresAsync_ptsz = 493
    CUPTI_DRIVER_TRACE_CBID_cuDestroyExternalSemaphore = 494
    CUPTI_DRIVER_TRACE_CBID_cuStreamBeginCapture = 495
    CUPTI_DRIVER_TRACE_CBID_cuStreamBeginCapture_ptsz = 496
    CUPTI_DRIVER_TRACE_CBID_cuStreamEndCapture = 497
    CUPTI_DRIVER_TRACE_CBID_cuStreamEndCapture_ptsz = 498
    CUPTI_DRIVER_TRACE_CBID_cuStreamIsCapturing = 499
    CUPTI_DRIVER_TRACE_CBID_cuStreamIsCapturing_ptsz = 500
    CUPTI_DRIVER_TRACE_CBID_cuGraphCreate = 501
    CUPTI_DRIVER_TRACE_CBID_cuGraphAddKernelNode = 502
    CUPTI_DRIVER_TRACE_CBID_cuGraphKernelNodeGetParams = 503
    CUPTI_DRIVER_TRACE_CBID_cuGraphAddMemcpyNode = 504
    CUPTI_DRIVER_TRACE_CBID_cuGraphMemcpyNodeGetParams = 505
    CUPTI_DRIVER_TRACE_CBID_cuGraphAddMemsetNode = 506
    CUPTI_DRIVER_TRACE_CBID_cuGraphMemsetNodeGetParams = 507
    CUPTI_DRIVER_TRACE_CBID_cuGraphMemsetNodeSetParams = 508
    CUPTI_DRIVER_TRACE_CBID_cuGraphNodeGetType = 509
    CUPTI_DRIVER_TRACE_CBID_cuGraphGetRootNodes = 510
    CUPTI_DRIVER_TRACE_CBID_cuGraphNodeGetDependencies = 511
    CUPTI_DRIVER_TRACE_CBID_cuGraphNodeGetDependentNodes = 512
    CUPTI_DRIVER_TRACE_CBID_cuGraphInstantiate = 513
    CUPTI_DRIVER_TRACE_CBID_cuGraphLaunch = 514
    CUPTI_DRIVER_TRACE_CBID_cuGraphLaunch_ptsz = 515
    CUPTI_DRIVER_TRACE_CBID_cuGraphExecDestroy = 516
    CUPTI_DRIVER_TRACE_CBID_cuGraphDestroy = 517
    CUPTI_DRIVER_TRACE_CBID_cuGraphAddDependencies = 518
    CUPTI_DRIVER_TRACE_CBID_cuGraphRemoveDependencies = 519
    CUPTI_DRIVER_TRACE_CBID_cuGraphMemcpyNodeSetParams = 520
    CUPTI_DRIVER_TRACE_CBID_cuGraphKernelNodeSetParams = 521
    CUPTI_DRIVER_TRACE_CBID_cuGraphDestroyNode = 522
    CUPTI_DRIVER_TRACE_CBID_cuGraphClone = 523
    CUPTI_DRIVER_TRACE_CBID_cuGraphNodeFindInClone = 524
    CUPTI_DRIVER_TRACE_CBID_cuGraphAddChildGraphNode = 525
    CUPTI_DRIVER_TRACE_CBID_cuGraphAddEmptyNode = 526
    CUPTI_DRIVER_TRACE_CBID_cuLaunchHostFunc = 527
    CUPTI_DRIVER_TRACE_CBID_cuLaunchHostFunc_ptsz = 528
    CUPTI_DRIVER_TRACE_CBID_cuGraphChildGraphNodeGetGraph = 529
    CUPTI_DRIVER_TRACE_CBID_cuGraphAddHostNode = 530
    CUPTI_DRIVER_TRACE_CBID_cuGraphHostNodeGetParams = 531
    CUPTI_DRIVER_TRACE_CBID_cuDeviceGetLuid = 532
    CUPTI_DRIVER_TRACE_CBID_cuGraphHostNodeSetParams = 533
    CUPTI_DRIVER_TRACE_CBID_cuGraphGetNodes = 534
    CUPTI_DRIVER_TRACE_CBID_cuGraphGetEdges = 535
    CUPTI_DRIVER_TRACE_CBID_cuStreamGetCaptureInfo = 536
    CUPTI_DRIVER_TRACE_CBID_cuStreamGetCaptureInfo_ptsz = 537
    CUPTI_DRIVER_TRACE_CBID_cuGraphExecKernelNodeSetParams = 538
    CUPTI_DRIVER_TRACE_CBID_cuStreamBeginCapture_v2 = 539
    CUPTI_DRIVER_TRACE_CBID_cuStreamBeginCapture_v2_ptsz = 540
    CUPTI_DRIVER_TRACE_CBID_cuThreadExchangeStreamCaptureMode = 541
    CUPTI_DRIVER_TRACE_CBID_cuDeviceGetNvSciSyncAttributes = 542
    CUPTI_DRIVER_TRACE_CBID_cuOccupancyAvailableDynamicSMemPerBlock = 543
    CUPTI_DRIVER_TRACE_CBID_cuDevicePrimaryCtxRelease_v2 = 544
    CUPTI_DRIVER_TRACE_CBID_cuDevicePrimaryCtxReset_v2 = 545
    CUPTI_DRIVER_TRACE_CBID_cuDevicePrimaryCtxSetFlags_v2 = 546
    CUPTI_DRIVER_TRACE_CBID_cuMemAddressReserve = 547
    CUPTI_DRIVER_TRACE_CBID_cuMemAddressFree = 548
    CUPTI_DRIVER_TRACE_CBID_cuMemCreate = 549
    CUPTI_DRIVER_TRACE_CBID_cuMemRelease = 550
    CUPTI_DRIVER_TRACE_CBID_cuMemMap = 551
    CUPTI_DRIVER_TRACE_CBID_cuMemUnmap = 552
    CUPTI_DRIVER_TRACE_CBID_cuMemSetAccess = 553
    CUPTI_DRIVER_TRACE_CBID_cuMemExportToShareableHandle = 554
    CUPTI_DRIVER_TRACE_CBID_cuMemImportFromShareableHandle = 555
    CUPTI_DRIVER_TRACE_CBID_cuMemGetAllocationGranularity = 556
    CUPTI_DRIVER_TRACE_CBID_cuMemGetAllocationPropertiesFromHandle = 557
    CUPTI_DRIVER_TRACE_CBID_cuMemGetAccess = 558
    CUPTI_DRIVER_TRACE_CBID_cuStreamSetFlags = 559
    CUPTI_DRIVER_TRACE_CBID_cuStreamSetFlags_ptsz = 560
    CUPTI_DRIVER_TRACE_CBID_cuGraphExecUpdate = 561
    CUPTI_DRIVER_TRACE_CBID_cuGraphExecMemcpyNodeSetParams = 562
    CUPTI_DRIVER_TRACE_CBID_cuGraphExecMemsetNodeSetParams = 563
    CUPTI_DRIVER_TRACE_CBID_cuGraphExecHostNodeSetParams = 564
    CUPTI_DRIVER_TRACE_CBID_cuMemRetainAllocationHandle = 565
    CUPTI_DRIVER_TRACE_CBID_cuFuncGetModule = 566
    CUPTI_DRIVER_TRACE_CBID_cuIpcOpenMemHandle_v2 = 567
    CUPTI_DRIVER_TRACE_CBID_cuCtxResetPersistingL2Cache = 568
    CUPTI_DRIVER_TRACE_CBID_cuGraphKernelNodeCopyAttributes = 569
    CUPTI_DRIVER_TRACE_CBID_cuGraphKernelNodeGetAttribute = 570
    CUPTI_DRIVER_TRACE_CBID_cuGraphKernelNodeSetAttribute = 571
    CUPTI_DRIVER_TRACE_CBID_cuStreamCopyAttributes = 572
    CUPTI_DRIVER_TRACE_CBID_cuStreamCopyAttributes_ptsz = 573
    CUPTI_DRIVER_TRACE_CBID_cuStreamGetAttribute = 574
    CUPTI_DRIVER_TRACE_CBID_cuStreamGetAttribute_ptsz = 575
    CUPTI_DRIVER_TRACE_CBID_cuStreamSetAttribute = 576
    CUPTI_DRIVER_TRACE_CBID_cuStreamSetAttribute_ptsz = 577
    CUPTI_DRIVER_TRACE_CBID_cuGraphInstantiate_v2 = 578
    CUPTI_DRIVER_TRACE_CBID_cuDeviceGetTexture1DLinearMaxWidth = 579
    CUPTI_DRIVER_TRACE_CBID_cuGraphUpload = 580
    CUPTI_DRIVER_TRACE_CBID_cuGraphUpload_ptsz = 581
    CUPTI_DRIVER_TRACE_CBID_cuArrayGetSparseProperties = 582
    CUPTI_DRIVER_TRACE_CBID_cuMipmappedArrayGetSparseProperties = 583
    CUPTI_DRIVER_TRACE_CBID_cuMemMapArrayAsync = 584
    CUPTI_DRIVER_TRACE_CBID_cuMemMapArrayAsync_ptsz = 585
    CUPTI_DRIVER_TRACE_CBID_cuGraphExecChildGraphNodeSetParams = 586
    CUPTI_DRIVER_TRACE_CBID_cuEventRecordWithFlags = 587
    CUPTI_DRIVER_TRACE_CBID_cuEventRecordWithFlags_ptsz = 588
    CUPTI_DRIVER_TRACE_CBID_cuGraphAddEventRecordNode = 589
    CUPTI_DRIVER_TRACE_CBID_cuGraphAddEventWaitNode = 590
    CUPTI_DRIVER_TRACE_CBID_cuGraphEventRecordNodeGetEvent = 591
    CUPTI_DRIVER_TRACE_CBID_cuGraphEventWaitNodeGetEvent = 592
    CUPTI_DRIVER_TRACE_CBID_cuGraphEventRecordNodeSetEvent = 593
    CUPTI_DRIVER_TRACE_CBID_cuGraphEventWaitNodeSetEvent = 594
    CUPTI_DRIVER_TRACE_CBID_cuGraphExecEventRecordNodeSetEvent = 595
    CUPTI_DRIVER_TRACE_CBID_cuGraphExecEventWaitNodeSetEvent = 596
    CUPTI_DRIVER_TRACE_CBID_cuArrayGetPlane = 597
    CUPTI_DRIVER_TRACE_CBID_cuMemAllocAsync = 598
    CUPTI_DRIVER_TRACE_CBID_cuMemAllocAsync_ptsz = 599
    CUPTI_DRIVER_TRACE_CBID_cuMemFreeAsync = 600
    CUPTI_DRIVER_TRACE_CBID_cuMemFreeAsync_ptsz = 601
    CUPTI_DRIVER_TRACE_CBID_cuMemPoolTrimTo = 602
    CUPTI_DRIVER_TRACE_CBID_cuMemPoolSetAttribute = 603
    CUPTI_DRIVER_TRACE_CBID_cuMemPoolGetAttribute = 604
    CUPTI_DRIVER_TRACE_CBID_cuMemPoolSetAccess = 605
    CUPTI_DRIVER_TRACE_CBID_cuDeviceGetDefaultMemPool = 606
    CUPTI_DRIVER_TRACE_CBID_cuMemPoolCreate = 607
    CUPTI_DRIVER_TRACE_CBID_cuMemPoolDestroy = 608
    CUPTI_DRIVER_TRACE_CBID_cuDeviceSetMemPool = 609
    CUPTI_DRIVER_TRACE_CBID_cuDeviceGetMemPool = 610
    CUPTI_DRIVER_TRACE_CBID_cuMemAllocFromPoolAsync = 611
    CUPTI_DRIVER_TRACE_CBID_cuMemAllocFromPoolAsync_ptsz = 612
    CUPTI_DRIVER_TRACE_CBID_cuMemPoolExportToShareableHandle = 613
    CUPTI_DRIVER_TRACE_CBID_cuMemPoolImportFromShareableHandle = 614
    CUPTI_DRIVER_TRACE_CBID_cuMemPoolExportPointer = 615
    CUPTI_DRIVER_TRACE_CBID_cuMemPoolImportPointer = 616
    CUPTI_DRIVER_TRACE_CBID_cuMemPoolGetAccess = 617
    CUPTI_DRIVER_TRACE_CBID_cuGraphAddExternalSemaphoresSignalNode = 618
    CUPTI_DRIVER_TRACE_CBID_cuGraphExternalSemaphoresSignalNodeGetParams = 619
    CUPTI_DRIVER_TRACE_CBID_cuGraphExternalSemaphoresSignalNodeSetParams = 620
    CUPTI_DRIVER_TRACE_CBID_cuGraphAddExternalSemaphoresWaitNode = 621
    CUPTI_DRIVER_TRACE_CBID_cuGraphExternalSemaphoresWaitNodeGetParams = 622
    CUPTI_DRIVER_TRACE_CBID_cuGraphExternalSemaphoresWaitNodeSetParams = 623
    CUPTI_DRIVER_TRACE_CBID_cuGraphExecExternalSemaphoresSignalNodeSetParams = 624
    CUPTI_DRIVER_TRACE_CBID_cuGraphExecExternalSemaphoresWaitNodeSetParams = 625
    CUPTI_DRIVER_TRACE_CBID_cuGetProcAddress = 626
    CUPTI_DRIVER_TRACE_CBID_cuFlushGPUDirectRDMAWrites = 627
    CUPTI_DRIVER_TRACE_CBID_cuGraphDebugDotPrint = 628
    CUPTI_DRIVER_TRACE_CBID_cuStreamGetCaptureInfo_v2 = 629
    CUPTI_DRIVER_TRACE_CBID_cuStreamGetCaptureInfo_v2_ptsz = 630
    CUPTI_DRIVER_TRACE_CBID_cuStreamUpdateCaptureDependencies = 631
    CUPTI_DRIVER_TRACE_CBID_cuStreamUpdateCaptureDependencies_ptsz = 632
    CUPTI_DRIVER_TRACE_CBID_cuUserObjectCreate = 633
    CUPTI_DRIVER_TRACE_CBID_cuUserObjectRetain = 634
    CUPTI_DRIVER_TRACE_CBID_cuUserObjectRelease = 635
    CUPTI_DRIVER_TRACE_CBID_cuGraphRetainUserObject = 636
    CUPTI_DRIVER_TRACE_CBID_cuGraphReleaseUserObject = 637
    CUPTI_DRIVER_TRACE_CBID_cuGraphAddMemAllocNode = 638
    CUPTI_DRIVER_TRACE_CBID_cuGraphAddMemFreeNode = 639
    CUPTI_DRIVER_TRACE_CBID_cuDeviceGraphMemTrim = 640
    CUPTI_DRIVER_TRACE_CBID_cuDeviceGetGraphMemAttribute = 641
    CUPTI_DRIVER_TRACE_CBID_cuDeviceSetGraphMemAttribute = 642
    CUPTI_DRIVER_TRACE_CBID_cuGraphInstantiateWithFlags = 643
    CUPTI_DRIVER_TRACE_CBID_cuDeviceGetExecAffinitySupport = 644
    CUPTI_DRIVER_TRACE_CBID_cuCtxCreate_v3 = 645
    CUPTI_DRIVER_TRACE_CBID_cuCtxGetExecAffinity = 646
    CUPTI_DRIVER_TRACE_CBID_cuDeviceGetUuid_v2 = 647
    CUPTI_DRIVER_TRACE_CBID_cuGraphMemAllocNodeGetParams = 648
    CUPTI_DRIVER_TRACE_CBID_cuGraphMemFreeNodeGetParams = 649
    CUPTI_DRIVER_TRACE_CBID_cuGraphNodeSetEnabled = 650
    CUPTI_DRIVER_TRACE_CBID_cuGraphNodeGetEnabled = 651
    CUPTI_DRIVER_TRACE_CBID_cuLaunchKernelEx = 652
    CUPTI_DRIVER_TRACE_CBID_cuLaunchKernelEx_ptsz = 653
    CUPTI_DRIVER_TRACE_CBID_cuArrayGetMemoryRequirements = 654
    CUPTI_DRIVER_TRACE_CBID_cuMipmappedArrayGetMemoryRequirements = 655
    CUPTI_DRIVER_TRACE_CBID_cuGraphInstantiateWithParams = 656
    CUPTI_DRIVER_TRACE_CBID_cuGraphInstantiateWithParams_ptsz = 657
    CUPTI_DRIVER_TRACE_CBID_cuGraphExecGetFlags = 658
    CUPTI_DRIVER_TRACE_CBID_cuStreamWaitValue32_v2 = 659
    CUPTI_DRIVER_TRACE_CBID_cuStreamWaitValue32_v2_ptsz = 660
    CUPTI_DRIVER_TRACE_CBID_cuStreamWaitValue64_v2 = 661
    CUPTI_DRIVER_TRACE_CBID_cuStreamWaitValue64_v2_ptsz = 662
    CUPTI_DRIVER_TRACE_CBID_cuStreamWriteValue32_v2 = 663
    CUPTI_DRIVER_TRACE_CBID_cuStreamWriteValue32_v2_ptsz = 664
    CUPTI_DRIVER_TRACE_CBID_cuStreamWriteValue64_v2 = 665
    CUPTI_DRIVER_TRACE_CBID_cuStreamWriteValue64_v2_ptsz = 666
    CUPTI_DRIVER_TRACE_CBID_cuStreamBatchMemOp_v2 = 667
    CUPTI_DRIVER_TRACE_CBID_cuStreamBatchMemOp_v2_ptsz = 668
    CUPTI_DRIVER_TRACE_CBID_cuGraphAddBatchMemOpNode = 669
    CUPTI_DRIVER_TRACE_CBID_cuGraphBatchMemOpNodeGetParams = 670
    CUPTI_DRIVER_TRACE_CBID_cuGraphBatchMemOpNodeSetParams = 671
    CUPTI_DRIVER_TRACE_CBID_cuGraphExecBatchMemOpNodeSetParams = 672
    CUPTI_DRIVER_TRACE_CBID_cuModuleGetLoadingMode = 673
    CUPTI_DRIVER_TRACE_CBID_cuMemGetHandleForAddressRange = 674
    CUPTI_DRIVER_TRACE_CBID_cuOccupancyMaxPotentialClusterSize = 675
    CUPTI_DRIVER_TRACE_CBID_cuOccupancyMaxActiveClusters = 676
    CUPTI_DRIVER_TRACE_CBID_SIZE = 677
    CUPTI_DRIVER_TRACE_CBID_FORCE_INT = 2147483647
end

const CUpti_driver_api_trace_cbid = CUpti_driver_api_trace_cbid_enum

@cenum CUpti_runtime_api_trace_cbid_enum::UInt32 begin
    CUPTI_RUNTIME_TRACE_CBID_INVALID = 0
    CUPTI_RUNTIME_TRACE_CBID_cudaDriverGetVersion_v3020 = 1
    CUPTI_RUNTIME_TRACE_CBID_cudaRuntimeGetVersion_v3020 = 2
    CUPTI_RUNTIME_TRACE_CBID_cudaGetDeviceCount_v3020 = 3
    CUPTI_RUNTIME_TRACE_CBID_cudaGetDeviceProperties_v3020 = 4
    CUPTI_RUNTIME_TRACE_CBID_cudaChooseDevice_v3020 = 5
    CUPTI_RUNTIME_TRACE_CBID_cudaGetChannelDesc_v3020 = 6
    CUPTI_RUNTIME_TRACE_CBID_cudaCreateChannelDesc_v3020 = 7
    CUPTI_RUNTIME_TRACE_CBID_cudaConfigureCall_v3020 = 8
    CUPTI_RUNTIME_TRACE_CBID_cudaSetupArgument_v3020 = 9
    CUPTI_RUNTIME_TRACE_CBID_cudaGetLastError_v3020 = 10
    CUPTI_RUNTIME_TRACE_CBID_cudaPeekAtLastError_v3020 = 11
    CUPTI_RUNTIME_TRACE_CBID_cudaGetErrorString_v3020 = 12
    CUPTI_RUNTIME_TRACE_CBID_cudaLaunch_v3020 = 13
    CUPTI_RUNTIME_TRACE_CBID_cudaFuncSetCacheConfig_v3020 = 14
    CUPTI_RUNTIME_TRACE_CBID_cudaFuncGetAttributes_v3020 = 15
    CUPTI_RUNTIME_TRACE_CBID_cudaSetDevice_v3020 = 16
    CUPTI_RUNTIME_TRACE_CBID_cudaGetDevice_v3020 = 17
    CUPTI_RUNTIME_TRACE_CBID_cudaSetValidDevices_v3020 = 18
    CUPTI_RUNTIME_TRACE_CBID_cudaSetDeviceFlags_v3020 = 19
    CUPTI_RUNTIME_TRACE_CBID_cudaMalloc_v3020 = 20
    CUPTI_RUNTIME_TRACE_CBID_cudaMallocPitch_v3020 = 21
    CUPTI_RUNTIME_TRACE_CBID_cudaFree_v3020 = 22
    CUPTI_RUNTIME_TRACE_CBID_cudaMallocArray_v3020 = 23
    CUPTI_RUNTIME_TRACE_CBID_cudaFreeArray_v3020 = 24
    CUPTI_RUNTIME_TRACE_CBID_cudaMallocHost_v3020 = 25
    CUPTI_RUNTIME_TRACE_CBID_cudaFreeHost_v3020 = 26
    CUPTI_RUNTIME_TRACE_CBID_cudaHostAlloc_v3020 = 27
    CUPTI_RUNTIME_TRACE_CBID_cudaHostGetDevicePointer_v3020 = 28
    CUPTI_RUNTIME_TRACE_CBID_cudaHostGetFlags_v3020 = 29
    CUPTI_RUNTIME_TRACE_CBID_cudaMemGetInfo_v3020 = 30
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpy_v3020 = 31
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpy2D_v3020 = 32
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpyToArray_v3020 = 33
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpy2DToArray_v3020 = 34
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpyFromArray_v3020 = 35
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpy2DFromArray_v3020 = 36
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpyArrayToArray_v3020 = 37
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpy2DArrayToArray_v3020 = 38
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpyToSymbol_v3020 = 39
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpyFromSymbol_v3020 = 40
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpyAsync_v3020 = 41
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpyToArrayAsync_v3020 = 42
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpyFromArrayAsync_v3020 = 43
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpy2DAsync_v3020 = 44
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpy2DToArrayAsync_v3020 = 45
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpy2DFromArrayAsync_v3020 = 46
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpyToSymbolAsync_v3020 = 47
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpyFromSymbolAsync_v3020 = 48
    CUPTI_RUNTIME_TRACE_CBID_cudaMemset_v3020 = 49
    CUPTI_RUNTIME_TRACE_CBID_cudaMemset2D_v3020 = 50
    CUPTI_RUNTIME_TRACE_CBID_cudaMemsetAsync_v3020 = 51
    CUPTI_RUNTIME_TRACE_CBID_cudaMemset2DAsync_v3020 = 52
    CUPTI_RUNTIME_TRACE_CBID_cudaGetSymbolAddress_v3020 = 53
    CUPTI_RUNTIME_TRACE_CBID_cudaGetSymbolSize_v3020 = 54
    CUPTI_RUNTIME_TRACE_CBID_cudaBindTexture_v3020 = 55
    CUPTI_RUNTIME_TRACE_CBID_cudaBindTexture2D_v3020 = 56
    CUPTI_RUNTIME_TRACE_CBID_cudaBindTextureToArray_v3020 = 57
    CUPTI_RUNTIME_TRACE_CBID_cudaUnbindTexture_v3020 = 58
    CUPTI_RUNTIME_TRACE_CBID_cudaGetTextureAlignmentOffset_v3020 = 59
    CUPTI_RUNTIME_TRACE_CBID_cudaGetTextureReference_v3020 = 60
    CUPTI_RUNTIME_TRACE_CBID_cudaBindSurfaceToArray_v3020 = 61
    CUPTI_RUNTIME_TRACE_CBID_cudaGetSurfaceReference_v3020 = 62
    CUPTI_RUNTIME_TRACE_CBID_cudaGLSetGLDevice_v3020 = 63
    CUPTI_RUNTIME_TRACE_CBID_cudaGLRegisterBufferObject_v3020 = 64
    CUPTI_RUNTIME_TRACE_CBID_cudaGLMapBufferObject_v3020 = 65
    CUPTI_RUNTIME_TRACE_CBID_cudaGLUnmapBufferObject_v3020 = 66
    CUPTI_RUNTIME_TRACE_CBID_cudaGLUnregisterBufferObject_v3020 = 67
    CUPTI_RUNTIME_TRACE_CBID_cudaGLSetBufferObjectMapFlags_v3020 = 68
    CUPTI_RUNTIME_TRACE_CBID_cudaGLMapBufferObjectAsync_v3020 = 69
    CUPTI_RUNTIME_TRACE_CBID_cudaGLUnmapBufferObjectAsync_v3020 = 70
    CUPTI_RUNTIME_TRACE_CBID_cudaWGLGetDevice_v3020 = 71
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphicsGLRegisterImage_v3020 = 72
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphicsGLRegisterBuffer_v3020 = 73
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphicsUnregisterResource_v3020 = 74
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphicsResourceSetMapFlags_v3020 = 75
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphicsMapResources_v3020 = 76
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphicsUnmapResources_v3020 = 77
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphicsResourceGetMappedPointer_v3020 = 78
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphicsSubResourceGetMappedArray_v3020 = 79
    CUPTI_RUNTIME_TRACE_CBID_cudaVDPAUGetDevice_v3020 = 80
    CUPTI_RUNTIME_TRACE_CBID_cudaVDPAUSetVDPAUDevice_v3020 = 81
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphicsVDPAURegisterVideoSurface_v3020 = 82
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphicsVDPAURegisterOutputSurface_v3020 = 83
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D11GetDevice_v3020 = 84
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D11GetDevices_v3020 = 85
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D11SetDirect3DDevice_v3020 = 86
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphicsD3D11RegisterResource_v3020 = 87
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D10GetDevice_v3020 = 88
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D10GetDevices_v3020 = 89
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D10SetDirect3DDevice_v3020 = 90
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphicsD3D10RegisterResource_v3020 = 91
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D10RegisterResource_v3020 = 92
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D10UnregisterResource_v3020 = 93
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D10MapResources_v3020 = 94
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D10UnmapResources_v3020 = 95
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D10ResourceSetMapFlags_v3020 = 96
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D10ResourceGetSurfaceDimensions_v3020 = 97
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D10ResourceGetMappedArray_v3020 = 98
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D10ResourceGetMappedPointer_v3020 = 99
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D10ResourceGetMappedSize_v3020 = 100
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D10ResourceGetMappedPitch_v3020 = 101
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D9GetDevice_v3020 = 102
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D9GetDevices_v3020 = 103
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D9SetDirect3DDevice_v3020 = 104
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D9GetDirect3DDevice_v3020 = 105
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphicsD3D9RegisterResource_v3020 = 106
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D9RegisterResource_v3020 = 107
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D9UnregisterResource_v3020 = 108
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D9MapResources_v3020 = 109
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D9UnmapResources_v3020 = 110
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D9ResourceSetMapFlags_v3020 = 111
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D9ResourceGetSurfaceDimensions_v3020 = 112
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D9ResourceGetMappedArray_v3020 = 113
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D9ResourceGetMappedPointer_v3020 = 114
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D9ResourceGetMappedSize_v3020 = 115
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D9ResourceGetMappedPitch_v3020 = 116
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D9Begin_v3020 = 117
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D9End_v3020 = 118
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D9RegisterVertexBuffer_v3020 = 119
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D9UnregisterVertexBuffer_v3020 = 120
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D9MapVertexBuffer_v3020 = 121
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D9UnmapVertexBuffer_v3020 = 122
    CUPTI_RUNTIME_TRACE_CBID_cudaThreadExit_v3020 = 123
    CUPTI_RUNTIME_TRACE_CBID_cudaSetDoubleForDevice_v3020 = 124
    CUPTI_RUNTIME_TRACE_CBID_cudaSetDoubleForHost_v3020 = 125
    CUPTI_RUNTIME_TRACE_CBID_cudaThreadSynchronize_v3020 = 126
    CUPTI_RUNTIME_TRACE_CBID_cudaThreadGetLimit_v3020 = 127
    CUPTI_RUNTIME_TRACE_CBID_cudaThreadSetLimit_v3020 = 128
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamCreate_v3020 = 129
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamDestroy_v3020 = 130
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamSynchronize_v3020 = 131
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamQuery_v3020 = 132
    CUPTI_RUNTIME_TRACE_CBID_cudaEventCreate_v3020 = 133
    CUPTI_RUNTIME_TRACE_CBID_cudaEventCreateWithFlags_v3020 = 134
    CUPTI_RUNTIME_TRACE_CBID_cudaEventRecord_v3020 = 135
    CUPTI_RUNTIME_TRACE_CBID_cudaEventDestroy_v3020 = 136
    CUPTI_RUNTIME_TRACE_CBID_cudaEventSynchronize_v3020 = 137
    CUPTI_RUNTIME_TRACE_CBID_cudaEventQuery_v3020 = 138
    CUPTI_RUNTIME_TRACE_CBID_cudaEventElapsedTime_v3020 = 139
    CUPTI_RUNTIME_TRACE_CBID_cudaMalloc3D_v3020 = 140
    CUPTI_RUNTIME_TRACE_CBID_cudaMalloc3DArray_v3020 = 141
    CUPTI_RUNTIME_TRACE_CBID_cudaMemset3D_v3020 = 142
    CUPTI_RUNTIME_TRACE_CBID_cudaMemset3DAsync_v3020 = 143
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpy3D_v3020 = 144
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpy3DAsync_v3020 = 145
    CUPTI_RUNTIME_TRACE_CBID_cudaThreadSetCacheConfig_v3020 = 146
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamWaitEvent_v3020 = 147
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D11GetDirect3DDevice_v3020 = 148
    CUPTI_RUNTIME_TRACE_CBID_cudaD3D10GetDirect3DDevice_v3020 = 149
    CUPTI_RUNTIME_TRACE_CBID_cudaThreadGetCacheConfig_v3020 = 150
    CUPTI_RUNTIME_TRACE_CBID_cudaPointerGetAttributes_v4000 = 151
    CUPTI_RUNTIME_TRACE_CBID_cudaHostRegister_v4000 = 152
    CUPTI_RUNTIME_TRACE_CBID_cudaHostUnregister_v4000 = 153
    CUPTI_RUNTIME_TRACE_CBID_cudaDeviceCanAccessPeer_v4000 = 154
    CUPTI_RUNTIME_TRACE_CBID_cudaDeviceEnablePeerAccess_v4000 = 155
    CUPTI_RUNTIME_TRACE_CBID_cudaDeviceDisablePeerAccess_v4000 = 156
    CUPTI_RUNTIME_TRACE_CBID_cudaPeerRegister_v4000 = 157
    CUPTI_RUNTIME_TRACE_CBID_cudaPeerUnregister_v4000 = 158
    CUPTI_RUNTIME_TRACE_CBID_cudaPeerGetDevicePointer_v4000 = 159
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpyPeer_v4000 = 160
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpyPeerAsync_v4000 = 161
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpy3DPeer_v4000 = 162
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpy3DPeerAsync_v4000 = 163
    CUPTI_RUNTIME_TRACE_CBID_cudaDeviceReset_v3020 = 164
    CUPTI_RUNTIME_TRACE_CBID_cudaDeviceSynchronize_v3020 = 165
    CUPTI_RUNTIME_TRACE_CBID_cudaDeviceGetLimit_v3020 = 166
    CUPTI_RUNTIME_TRACE_CBID_cudaDeviceSetLimit_v3020 = 167
    CUPTI_RUNTIME_TRACE_CBID_cudaDeviceGetCacheConfig_v3020 = 168
    CUPTI_RUNTIME_TRACE_CBID_cudaDeviceSetCacheConfig_v3020 = 169
    CUPTI_RUNTIME_TRACE_CBID_cudaProfilerInitialize_v4000 = 170
    CUPTI_RUNTIME_TRACE_CBID_cudaProfilerStart_v4000 = 171
    CUPTI_RUNTIME_TRACE_CBID_cudaProfilerStop_v4000 = 172
    CUPTI_RUNTIME_TRACE_CBID_cudaDeviceGetByPCIBusId_v4010 = 173
    CUPTI_RUNTIME_TRACE_CBID_cudaDeviceGetPCIBusId_v4010 = 174
    CUPTI_RUNTIME_TRACE_CBID_cudaGLGetDevices_v4010 = 175
    CUPTI_RUNTIME_TRACE_CBID_cudaIpcGetEventHandle_v4010 = 176
    CUPTI_RUNTIME_TRACE_CBID_cudaIpcOpenEventHandle_v4010 = 177
    CUPTI_RUNTIME_TRACE_CBID_cudaIpcGetMemHandle_v4010 = 178
    CUPTI_RUNTIME_TRACE_CBID_cudaIpcOpenMemHandle_v4010 = 179
    CUPTI_RUNTIME_TRACE_CBID_cudaIpcCloseMemHandle_v4010 = 180
    CUPTI_RUNTIME_TRACE_CBID_cudaArrayGetInfo_v4010 = 181
    CUPTI_RUNTIME_TRACE_CBID_cudaFuncSetSharedMemConfig_v4020 = 182
    CUPTI_RUNTIME_TRACE_CBID_cudaDeviceGetSharedMemConfig_v4020 = 183
    CUPTI_RUNTIME_TRACE_CBID_cudaDeviceSetSharedMemConfig_v4020 = 184
    CUPTI_RUNTIME_TRACE_CBID_cudaCreateTextureObject_v5000 = 185
    CUPTI_RUNTIME_TRACE_CBID_cudaDestroyTextureObject_v5000 = 186
    CUPTI_RUNTIME_TRACE_CBID_cudaGetTextureObjectResourceDesc_v5000 = 187
    CUPTI_RUNTIME_TRACE_CBID_cudaGetTextureObjectTextureDesc_v5000 = 188
    CUPTI_RUNTIME_TRACE_CBID_cudaCreateSurfaceObject_v5000 = 189
    CUPTI_RUNTIME_TRACE_CBID_cudaDestroySurfaceObject_v5000 = 190
    CUPTI_RUNTIME_TRACE_CBID_cudaGetSurfaceObjectResourceDesc_v5000 = 191
    CUPTI_RUNTIME_TRACE_CBID_cudaMallocMipmappedArray_v5000 = 192
    CUPTI_RUNTIME_TRACE_CBID_cudaGetMipmappedArrayLevel_v5000 = 193
    CUPTI_RUNTIME_TRACE_CBID_cudaFreeMipmappedArray_v5000 = 194
    CUPTI_RUNTIME_TRACE_CBID_cudaBindTextureToMipmappedArray_v5000 = 195
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphicsResourceGetMappedMipmappedArray_v5000 = 196
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamAddCallback_v5000 = 197
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamCreateWithFlags_v5000 = 198
    CUPTI_RUNTIME_TRACE_CBID_cudaGetTextureObjectResourceViewDesc_v5000 = 199
    CUPTI_RUNTIME_TRACE_CBID_cudaDeviceGetAttribute_v5000 = 200
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamDestroy_v5050 = 201
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamCreateWithPriority_v5050 = 202
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamGetPriority_v5050 = 203
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamGetFlags_v5050 = 204
    CUPTI_RUNTIME_TRACE_CBID_cudaDeviceGetStreamPriorityRange_v5050 = 205
    CUPTI_RUNTIME_TRACE_CBID_cudaMallocManaged_v6000 = 206
    CUPTI_RUNTIME_TRACE_CBID_cudaOccupancyMaxActiveBlocksPerMultiprocessor_v6000 = 207
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamAttachMemAsync_v6000 = 208
    CUPTI_RUNTIME_TRACE_CBID_cudaGetErrorName_v6050 = 209
    CUPTI_RUNTIME_TRACE_CBID_cudaOccupancyMaxActiveBlocksPerMultiprocessor_v6050 = 210
    CUPTI_RUNTIME_TRACE_CBID_cudaLaunchKernel_v7000 = 211
    CUPTI_RUNTIME_TRACE_CBID_cudaGetDeviceFlags_v7000 = 212
    CUPTI_RUNTIME_TRACE_CBID_cudaLaunch_ptsz_v7000 = 213
    CUPTI_RUNTIME_TRACE_CBID_cudaLaunchKernel_ptsz_v7000 = 214
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpy_ptds_v7000 = 215
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpy2D_ptds_v7000 = 216
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpyToArray_ptds_v7000 = 217
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpy2DToArray_ptds_v7000 = 218
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpyFromArray_ptds_v7000 = 219
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpy2DFromArray_ptds_v7000 = 220
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpyArrayToArray_ptds_v7000 = 221
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpy2DArrayToArray_ptds_v7000 = 222
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpyToSymbol_ptds_v7000 = 223
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpyFromSymbol_ptds_v7000 = 224
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpyAsync_ptsz_v7000 = 225
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpyToArrayAsync_ptsz_v7000 = 226
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpyFromArrayAsync_ptsz_v7000 = 227
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpy2DAsync_ptsz_v7000 = 228
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpy2DToArrayAsync_ptsz_v7000 = 229
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpy2DFromArrayAsync_ptsz_v7000 = 230
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpyToSymbolAsync_ptsz_v7000 = 231
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpyFromSymbolAsync_ptsz_v7000 = 232
    CUPTI_RUNTIME_TRACE_CBID_cudaMemset_ptds_v7000 = 233
    CUPTI_RUNTIME_TRACE_CBID_cudaMemset2D_ptds_v7000 = 234
    CUPTI_RUNTIME_TRACE_CBID_cudaMemsetAsync_ptsz_v7000 = 235
    CUPTI_RUNTIME_TRACE_CBID_cudaMemset2DAsync_ptsz_v7000 = 236
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamGetPriority_ptsz_v7000 = 237
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamGetFlags_ptsz_v7000 = 238
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamSynchronize_ptsz_v7000 = 239
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamQuery_ptsz_v7000 = 240
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamAttachMemAsync_ptsz_v7000 = 241
    CUPTI_RUNTIME_TRACE_CBID_cudaEventRecord_ptsz_v7000 = 242
    CUPTI_RUNTIME_TRACE_CBID_cudaMemset3D_ptds_v7000 = 243
    CUPTI_RUNTIME_TRACE_CBID_cudaMemset3DAsync_ptsz_v7000 = 244
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpy3D_ptds_v7000 = 245
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpy3DAsync_ptsz_v7000 = 246
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamWaitEvent_ptsz_v7000 = 247
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamAddCallback_ptsz_v7000 = 248
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpy3DPeer_ptds_v7000 = 249
    CUPTI_RUNTIME_TRACE_CBID_cudaMemcpy3DPeerAsync_ptsz_v7000 = 250
    CUPTI_RUNTIME_TRACE_CBID_cudaOccupancyMaxActiveBlocksPerMultiprocessorWithFlags_v7000 = 251
    CUPTI_RUNTIME_TRACE_CBID_cudaMemPrefetchAsync_v8000 = 252
    CUPTI_RUNTIME_TRACE_CBID_cudaMemPrefetchAsync_ptsz_v8000 = 253
    CUPTI_RUNTIME_TRACE_CBID_cudaMemAdvise_v8000 = 254
    CUPTI_RUNTIME_TRACE_CBID_cudaDeviceGetP2PAttribute_v8000 = 255
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphicsEGLRegisterImage_v7000 = 256
    CUPTI_RUNTIME_TRACE_CBID_cudaEGLStreamConsumerConnect_v7000 = 257
    CUPTI_RUNTIME_TRACE_CBID_cudaEGLStreamConsumerDisconnect_v7000 = 258
    CUPTI_RUNTIME_TRACE_CBID_cudaEGLStreamConsumerAcquireFrame_v7000 = 259
    CUPTI_RUNTIME_TRACE_CBID_cudaEGLStreamConsumerReleaseFrame_v7000 = 260
    CUPTI_RUNTIME_TRACE_CBID_cudaEGLStreamProducerConnect_v7000 = 261
    CUPTI_RUNTIME_TRACE_CBID_cudaEGLStreamProducerDisconnect_v7000 = 262
    CUPTI_RUNTIME_TRACE_CBID_cudaEGLStreamProducerPresentFrame_v7000 = 263
    CUPTI_RUNTIME_TRACE_CBID_cudaEGLStreamProducerReturnFrame_v7000 = 264
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphicsResourceGetMappedEglFrame_v7000 = 265
    CUPTI_RUNTIME_TRACE_CBID_cudaMemRangeGetAttribute_v8000 = 266
    CUPTI_RUNTIME_TRACE_CBID_cudaMemRangeGetAttributes_v8000 = 267
    CUPTI_RUNTIME_TRACE_CBID_cudaEGLStreamConsumerConnectWithFlags_v7000 = 268
    CUPTI_RUNTIME_TRACE_CBID_cudaLaunchCooperativeKernel_v9000 = 269
    CUPTI_RUNTIME_TRACE_CBID_cudaLaunchCooperativeKernel_ptsz_v9000 = 270
    CUPTI_RUNTIME_TRACE_CBID_cudaEventCreateFromEGLSync_v9000 = 271
    CUPTI_RUNTIME_TRACE_CBID_cudaLaunchCooperativeKernelMultiDevice_v9000 = 272
    CUPTI_RUNTIME_TRACE_CBID_cudaFuncSetAttribute_v9000 = 273
    CUPTI_RUNTIME_TRACE_CBID_cudaImportExternalMemory_v10000 = 274
    CUPTI_RUNTIME_TRACE_CBID_cudaExternalMemoryGetMappedBuffer_v10000 = 275
    CUPTI_RUNTIME_TRACE_CBID_cudaExternalMemoryGetMappedMipmappedArray_v10000 = 276
    CUPTI_RUNTIME_TRACE_CBID_cudaDestroyExternalMemory_v10000 = 277
    CUPTI_RUNTIME_TRACE_CBID_cudaImportExternalSemaphore_v10000 = 278
    CUPTI_RUNTIME_TRACE_CBID_cudaSignalExternalSemaphoresAsync_v10000 = 279
    CUPTI_RUNTIME_TRACE_CBID_cudaSignalExternalSemaphoresAsync_ptsz_v10000 = 280
    CUPTI_RUNTIME_TRACE_CBID_cudaWaitExternalSemaphoresAsync_v10000 = 281
    CUPTI_RUNTIME_TRACE_CBID_cudaWaitExternalSemaphoresAsync_ptsz_v10000 = 282
    CUPTI_RUNTIME_TRACE_CBID_cudaDestroyExternalSemaphore_v10000 = 283
    CUPTI_RUNTIME_TRACE_CBID_cudaLaunchHostFunc_v10000 = 284
    CUPTI_RUNTIME_TRACE_CBID_cudaLaunchHostFunc_ptsz_v10000 = 285
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphCreate_v10000 = 286
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphKernelNodeGetParams_v10000 = 287
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphKernelNodeSetParams_v10000 = 288
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphAddKernelNode_v10000 = 289
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphAddMemcpyNode_v10000 = 290
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphMemcpyNodeGetParams_v10000 = 291
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphMemcpyNodeSetParams_v10000 = 292
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphAddMemsetNode_v10000 = 293
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphMemsetNodeGetParams_v10000 = 294
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphMemsetNodeSetParams_v10000 = 295
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphAddHostNode_v10000 = 296
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphHostNodeGetParams_v10000 = 297
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphAddChildGraphNode_v10000 = 298
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphChildGraphNodeGetGraph_v10000 = 299
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphAddEmptyNode_v10000 = 300
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphClone_v10000 = 301
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphNodeFindInClone_v10000 = 302
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphNodeGetType_v10000 = 303
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphGetRootNodes_v10000 = 304
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphNodeGetDependencies_v10000 = 305
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphNodeGetDependentNodes_v10000 = 306
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphAddDependencies_v10000 = 307
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphRemoveDependencies_v10000 = 308
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphDestroyNode_v10000 = 309
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphInstantiate_v10000 = 310
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphLaunch_v10000 = 311
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphLaunch_ptsz_v10000 = 312
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphExecDestroy_v10000 = 313
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphDestroy_v10000 = 314
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamBeginCapture_v10000 = 315
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamBeginCapture_ptsz_v10000 = 316
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamIsCapturing_v10000 = 317
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamIsCapturing_ptsz_v10000 = 318
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamEndCapture_v10000 = 319
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamEndCapture_ptsz_v10000 = 320
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphHostNodeSetParams_v10000 = 321
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphGetNodes_v10000 = 322
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphGetEdges_v10000 = 323
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamGetCaptureInfo_v10010 = 324
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamGetCaptureInfo_ptsz_v10010 = 325
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphExecKernelNodeSetParams_v10010 = 326
    CUPTI_RUNTIME_TRACE_CBID_cudaThreadExchangeStreamCaptureMode_v10010 = 327
    CUPTI_RUNTIME_TRACE_CBID_cudaDeviceGetNvSciSyncAttributes_v10020 = 328
    CUPTI_RUNTIME_TRACE_CBID_cudaOccupancyAvailableDynamicSMemPerBlock_v10200 = 329
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamSetFlags_v10200 = 330
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamSetFlags_ptsz_v10200 = 331
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphExecMemcpyNodeSetParams_v10020 = 332
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphExecMemsetNodeSetParams_v10020 = 333
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphExecHostNodeSetParams_v10020 = 334
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphExecUpdate_v10020 = 335
    CUPTI_RUNTIME_TRACE_CBID_cudaGetFuncBySymbol_v11000 = 336
    CUPTI_RUNTIME_TRACE_CBID_cudaCtxResetPersistingL2Cache_v11000 = 337
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphKernelNodeCopyAttributes_v11000 = 338
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphKernelNodeGetAttribute_v11000 = 339
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphKernelNodeSetAttribute_v11000 = 340
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamCopyAttributes_v11000 = 341
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamCopyAttributes_ptsz_v11000 = 342
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamGetAttribute_v11000 = 343
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamGetAttribute_ptsz_v11000 = 344
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamSetAttribute_v11000 = 345
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamSetAttribute_ptsz_v11000 = 346
    CUPTI_RUNTIME_TRACE_CBID_cudaDeviceGetTexture1DLinearMaxWidth_v11010 = 347
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphUpload_v10000 = 348
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphUpload_ptsz_v10000 = 349
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphAddMemcpyNodeToSymbol_v11010 = 350
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphAddMemcpyNodeFromSymbol_v11010 = 351
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphAddMemcpyNode1D_v11010 = 352
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphMemcpyNodeSetParamsToSymbol_v11010 = 353
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphMemcpyNodeSetParamsFromSymbol_v11010 = 354
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphMemcpyNodeSetParams1D_v11010 = 355
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphExecMemcpyNodeSetParamsToSymbol_v11010 = 356
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphExecMemcpyNodeSetParamsFromSymbol_v11010 = 357
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphExecMemcpyNodeSetParams1D_v11010 = 358
    CUPTI_RUNTIME_TRACE_CBID_cudaArrayGetSparseProperties_v11010 = 359
    CUPTI_RUNTIME_TRACE_CBID_cudaMipmappedArrayGetSparseProperties_v11010 = 360
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphExecChildGraphNodeSetParams_v11010 = 361
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphAddEventRecordNode_v11010 = 362
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphEventRecordNodeGetEvent_v11010 = 363
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphEventRecordNodeSetEvent_v11010 = 364
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphAddEventWaitNode_v11010 = 365
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphEventWaitNodeGetEvent_v11010 = 366
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphEventWaitNodeSetEvent_v11010 = 367
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphExecEventRecordNodeSetEvent_v11010 = 368
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphExecEventWaitNodeSetEvent_v11010 = 369
    CUPTI_RUNTIME_TRACE_CBID_cudaEventRecordWithFlags_v11010 = 370
    CUPTI_RUNTIME_TRACE_CBID_cudaEventRecordWithFlags_ptsz_v11010 = 371
    CUPTI_RUNTIME_TRACE_CBID_cudaDeviceGetDefaultMemPool_v11020 = 372
    CUPTI_RUNTIME_TRACE_CBID_cudaMallocAsync_v11020 = 373
    CUPTI_RUNTIME_TRACE_CBID_cudaMallocAsync_ptsz_v11020 = 374
    CUPTI_RUNTIME_TRACE_CBID_cudaFreeAsync_v11020 = 375
    CUPTI_RUNTIME_TRACE_CBID_cudaFreeAsync_ptsz_v11020 = 376
    CUPTI_RUNTIME_TRACE_CBID_cudaMemPoolTrimTo_v11020 = 377
    CUPTI_RUNTIME_TRACE_CBID_cudaMemPoolSetAttribute_v11020 = 378
    CUPTI_RUNTIME_TRACE_CBID_cudaMemPoolGetAttribute_v11020 = 379
    CUPTI_RUNTIME_TRACE_CBID_cudaMemPoolSetAccess_v11020 = 380
    CUPTI_RUNTIME_TRACE_CBID_cudaArrayGetPlane_v11020 = 381
    CUPTI_RUNTIME_TRACE_CBID_cudaMemPoolGetAccess_v11020 = 382
    CUPTI_RUNTIME_TRACE_CBID_cudaMemPoolCreate_v11020 = 383
    CUPTI_RUNTIME_TRACE_CBID_cudaMemPoolDestroy_v11020 = 384
    CUPTI_RUNTIME_TRACE_CBID_cudaDeviceSetMemPool_v11020 = 385
    CUPTI_RUNTIME_TRACE_CBID_cudaDeviceGetMemPool_v11020 = 386
    CUPTI_RUNTIME_TRACE_CBID_cudaMemPoolExportToShareableHandle_v11020 = 387
    CUPTI_RUNTIME_TRACE_CBID_cudaMemPoolImportFromShareableHandle_v11020 = 388
    CUPTI_RUNTIME_TRACE_CBID_cudaMemPoolExportPointer_v11020 = 389
    CUPTI_RUNTIME_TRACE_CBID_cudaMemPoolImportPointer_v11020 = 390
    CUPTI_RUNTIME_TRACE_CBID_cudaMallocFromPoolAsync_v11020 = 391
    CUPTI_RUNTIME_TRACE_CBID_cudaMallocFromPoolAsync_ptsz_v11020 = 392
    CUPTI_RUNTIME_TRACE_CBID_cudaSignalExternalSemaphoresAsync_v2_v11020 = 393
    CUPTI_RUNTIME_TRACE_CBID_cudaSignalExternalSemaphoresAsync_v2_ptsz_v11020 = 394
    CUPTI_RUNTIME_TRACE_CBID_cudaWaitExternalSemaphoresAsync_v2_v11020 = 395
    CUPTI_RUNTIME_TRACE_CBID_cudaWaitExternalSemaphoresAsync_v2_ptsz_v11020 = 396
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphAddExternalSemaphoresSignalNode_v11020 = 397
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphExternalSemaphoresSignalNodeGetParams_v11020 = 398
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphExternalSemaphoresSignalNodeSetParams_v11020 = 399
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphAddExternalSemaphoresWaitNode_v11020 = 400
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphExternalSemaphoresWaitNodeGetParams_v11020 = 401
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphExternalSemaphoresWaitNodeSetParams_v11020 = 402
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphExecExternalSemaphoresSignalNodeSetParams_v11020 = 403
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphExecExternalSemaphoresWaitNodeSetParams_v11020 = 404
    CUPTI_RUNTIME_TRACE_CBID_cudaDeviceFlushGPUDirectRDMAWrites_v11030 = 405
    CUPTI_RUNTIME_TRACE_CBID_cudaGetDriverEntryPoint_v11030 = 406
    CUPTI_RUNTIME_TRACE_CBID_cudaGetDriverEntryPoint_ptsz_v11030 = 407
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphDebugDotPrint_v11030 = 408
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamGetCaptureInfo_v2_v11030 = 409
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamGetCaptureInfo_v2_ptsz_v11030 = 410
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamUpdateCaptureDependencies_v11030 = 411
    CUPTI_RUNTIME_TRACE_CBID_cudaStreamUpdateCaptureDependencies_ptsz_v11030 = 412
    CUPTI_RUNTIME_TRACE_CBID_cudaUserObjectCreate_v11030 = 413
    CUPTI_RUNTIME_TRACE_CBID_cudaUserObjectRetain_v11030 = 414
    CUPTI_RUNTIME_TRACE_CBID_cudaUserObjectRelease_v11030 = 415
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphRetainUserObject_v11030 = 416
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphReleaseUserObject_v11030 = 417
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphInstantiateWithFlags_v11040 = 418
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphAddMemAllocNode_v11040 = 419
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphMemAllocNodeGetParams_v11040 = 420
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphAddMemFreeNode_v11040 = 421
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphMemFreeNodeGetParams_v11040 = 422
    CUPTI_RUNTIME_TRACE_CBID_cudaDeviceGraphMemTrim_v11040 = 423
    CUPTI_RUNTIME_TRACE_CBID_cudaDeviceGetGraphMemAttribute_v11040 = 424
    CUPTI_RUNTIME_TRACE_CBID_cudaDeviceSetGraphMemAttribute_v11040 = 425
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphNodeSetEnabled_v11060 = 426
    CUPTI_RUNTIME_TRACE_CBID_cudaGraphNodeGetEnabled_v11060 = 427
    CUPTI_RUNTIME_TRACE_CBID_cudaArrayGetMemoryRequirements_v11060 = 428
    CUPTI_RUNTIME_TRACE_CBID_cudaMipmappedArrayGetMemoryRequirements_v11060 = 429
    CUPTI_RUNTIME_TRACE_CBID_cudaLaunchKernelExC_v11060 = 430
    CUPTI_RUNTIME_TRACE_CBID_cudaLaunchKernelExC_ptsz_v11060 = 431
    CUPTI_RUNTIME_TRACE_CBID_cudaOccupancyMaxPotentialClusterSize_v11070 = 432
    CUPTI_RUNTIME_TRACE_CBID_cudaOccupancyMaxActiveClusters_v11070 = 433
    CUPTI_RUNTIME_TRACE_CBID_SIZE = 434
    CUPTI_RUNTIME_TRACE_CBID_FORCE_INT = 2147483647
end

const CUpti_runtime_api_trace_cbid = CUpti_runtime_api_trace_cbid_enum

@cenum CUpti_nvtx_api_trace_cbid::UInt32 begin
    CUPTI_CBID_NVTX_INVALID = 0
    CUPTI_CBID_NVTX_nvtxMarkA = 1
    CUPTI_CBID_NVTX_nvtxMarkW = 2
    CUPTI_CBID_NVTX_nvtxMarkEx = 3
    CUPTI_CBID_NVTX_nvtxRangeStartA = 4
    CUPTI_CBID_NVTX_nvtxRangeStartW = 5
    CUPTI_CBID_NVTX_nvtxRangeStartEx = 6
    CUPTI_CBID_NVTX_nvtxRangeEnd = 7
    CUPTI_CBID_NVTX_nvtxRangePushA = 8
    CUPTI_CBID_NVTX_nvtxRangePushW = 9
    CUPTI_CBID_NVTX_nvtxRangePushEx = 10
    CUPTI_CBID_NVTX_nvtxRangePop = 11
    CUPTI_CBID_NVTX_nvtxNameCategoryA = 12
    CUPTI_CBID_NVTX_nvtxNameCategoryW = 13
    CUPTI_CBID_NVTX_nvtxNameOsThreadA = 14
    CUPTI_CBID_NVTX_nvtxNameOsThreadW = 15
    CUPTI_CBID_NVTX_nvtxNameCuDeviceA = 16
    CUPTI_CBID_NVTX_nvtxNameCuDeviceW = 17
    CUPTI_CBID_NVTX_nvtxNameCuContextA = 18
    CUPTI_CBID_NVTX_nvtxNameCuContextW = 19
    CUPTI_CBID_NVTX_nvtxNameCuStreamA = 20
    CUPTI_CBID_NVTX_nvtxNameCuStreamW = 21
    CUPTI_CBID_NVTX_nvtxNameCuEventA = 22
    CUPTI_CBID_NVTX_nvtxNameCuEventW = 23
    CUPTI_CBID_NVTX_nvtxNameCudaDeviceA = 24
    CUPTI_CBID_NVTX_nvtxNameCudaDeviceW = 25
    CUPTI_CBID_NVTX_nvtxNameCudaStreamA = 26
    CUPTI_CBID_NVTX_nvtxNameCudaStreamW = 27
    CUPTI_CBID_NVTX_nvtxNameCudaEventA = 28
    CUPTI_CBID_NVTX_nvtxNameCudaEventW = 29
    CUPTI_CBID_NVTX_nvtxDomainMarkEx = 30
    CUPTI_CBID_NVTX_nvtxDomainRangeStartEx = 31
    CUPTI_CBID_NVTX_nvtxDomainRangeEnd = 32
    CUPTI_CBID_NVTX_nvtxDomainRangePushEx = 33
    CUPTI_CBID_NVTX_nvtxDomainRangePop = 34
    CUPTI_CBID_NVTX_nvtxDomainResourceCreate = 35
    CUPTI_CBID_NVTX_nvtxDomainResourceDestroy = 36
    CUPTI_CBID_NVTX_nvtxDomainNameCategoryA = 37
    CUPTI_CBID_NVTX_nvtxDomainNameCategoryW = 38
    CUPTI_CBID_NVTX_nvtxDomainRegisterStringA = 39
    CUPTI_CBID_NVTX_nvtxDomainRegisterStringW = 40
    CUPTI_CBID_NVTX_nvtxDomainCreateA = 41
    CUPTI_CBID_NVTX_nvtxDomainCreateW = 42
    CUPTI_CBID_NVTX_nvtxDomainDestroy = 43
    CUPTI_CBID_NVTX_nvtxDomainSyncUserCreate = 44
    CUPTI_CBID_NVTX_nvtxDomainSyncUserDestroy = 45
    CUPTI_CBID_NVTX_nvtxDomainSyncUserAcquireStart = 46
    CUPTI_CBID_NVTX_nvtxDomainSyncUserAcquireFailed = 47
    CUPTI_CBID_NVTX_nvtxDomainSyncUserAcquireSuccess = 48
    CUPTI_CBID_NVTX_nvtxDomainSyncUserReleasing = 49
    CUPTI_CBID_NVTX_SIZE = 50
    CUPTI_CBID_NVTX_FORCE_INT = 2147483647
end

struct CUpti_Profiler_Initialize_Params
    structSize::Csize_t
    pPriv::Ptr{Cvoid}
end

struct CUpti_Profiler_DeInitialize_Params
    structSize::Csize_t
    pPriv::Ptr{Cvoid}
end

struct CUpti_Profiler_CounterDataImageOptions
    structSize::Csize_t
    pPriv::Ptr{Cvoid}
    pCounterDataPrefix::Ptr{UInt8}
    counterDataPrefixSize::Csize_t
    maxNumRanges::UInt32
    maxNumRangeTreeNodes::UInt32
    maxRangeNameLength::UInt32
end

struct CUpti_Profiler_CounterDataImage_CalculateSize_Params
    structSize::Csize_t
    pPriv::Ptr{Cvoid}
    sizeofCounterDataImageOptions::Csize_t
    pOptions::Ptr{CUpti_Profiler_CounterDataImageOptions}
    counterDataImageSize::Csize_t
end

struct CUpti_Profiler_CounterDataImage_Initialize_Params
    structSize::Csize_t
    pPriv::Ptr{Cvoid}
    sizeofCounterDataImageOptions::Csize_t
    pOptions::Ptr{CUpti_Profiler_CounterDataImageOptions}
    counterDataImageSize::Csize_t
    pCounterDataImage::Ptr{UInt8}
end

struct CUpti_Profiler_CounterDataImage_CalculateScratchBufferSize_Params
    structSize::Csize_t
    pPriv::Ptr{Cvoid}
    counterDataImageSize::Csize_t
    pCounterDataImage::Ptr{UInt8}
    counterDataScratchBufferSize::Csize_t
end

struct CUpti_Profiler_CounterDataImage_InitializeScratchBuffer_Params
    structSize::Csize_t
    pPriv::Ptr{Cvoid}
    counterDataImageSize::Csize_t
    pCounterDataImage::Ptr{UInt8}
    counterDataScratchBufferSize::Csize_t
    pCounterDataScratchBuffer::Ptr{UInt8}
end

@cenum CUpti_ProfilerRange::UInt32 begin
    CUPTI_Range_INVALID = 0
    CUPTI_AutoRange = 1
    CUPTI_UserRange = 2
    CUPTI_Range_COUNT = 3
end

@cenum CUpti_ProfilerReplayMode::UInt32 begin
    CUPTI_Replay_INVALID = 0
    CUPTI_ApplicationReplay = 1
    CUPTI_KernelReplay = 2
    CUPTI_UserReplay = 3
    CUPTI_Replay_COUNT = 4
end

struct CUpti_Profiler_BeginSession_Params
    structSize::Csize_t
    pPriv::Ptr{Cvoid}
    ctx::CUcontext
    counterDataImageSize::Csize_t
    pCounterDataImage::Ptr{UInt8}
    counterDataScratchBufferSize::Csize_t
    pCounterDataScratchBuffer::Ptr{UInt8}
    bDumpCounterDataInFile::UInt8
    pCounterDataFilePath::Cstring
    range::CUpti_ProfilerRange
    replayMode::CUpti_ProfilerReplayMode
    maxRangesPerPass::Csize_t
    maxLaunchesPerPass::Csize_t
end

struct CUpti_Profiler_EndSession_Params
    structSize::Csize_t
    pPriv::Ptr{Cvoid}
    ctx::CUcontext
end

struct CUpti_Profiler_SetConfig_Params
    structSize::Csize_t
    pPriv::Ptr{Cvoid}
    ctx::CUcontext
    pConfig::Ptr{UInt8}
    configSize::Csize_t
    minNestingLevel::UInt16
    numNestingLevels::UInt16
    passIndex::Csize_t
    targetNestingLevel::UInt16
end

struct CUpti_Profiler_UnsetConfig_Params
    structSize::Csize_t
    pPriv::Ptr{Cvoid}
    ctx::CUcontext
end

struct CUpti_Profiler_BeginPass_Params
    structSize::Csize_t
    pPriv::Ptr{Cvoid}
    ctx::CUcontext
end

struct CUpti_Profiler_EndPass_Params
    structSize::Csize_t
    pPriv::Ptr{Cvoid}
    ctx::CUcontext
    targetNestingLevel::UInt16
    passIndex::Csize_t
    allPassesSubmitted::UInt8
end

struct CUpti_Profiler_EnableProfiling_Params
    structSize::Csize_t
    pPriv::Ptr{Cvoid}
    ctx::CUcontext
end

struct CUpti_Profiler_DisableProfiling_Params
    structSize::Csize_t
    pPriv::Ptr{Cvoid}
    ctx::CUcontext
end

struct CUpti_Profiler_IsPassCollected_Params
    structSize::Csize_t
    pPriv::Ptr{Cvoid}
    ctx::CUcontext
    numRangesDropped::Csize_t
    numTraceBytesDropped::Csize_t
    onePassCollected::UInt8
    allPassesCollected::UInt8
end

struct CUpti_Profiler_FlushCounterData_Params
    structSize::Csize_t
    pPriv::Ptr{Cvoid}
    ctx::CUcontext
    numRangesDropped::Csize_t
    numTraceBytesDropped::Csize_t
end

struct CUpti_Profiler_PushRange_Params
    structSize::Csize_t
    pPriv::Ptr{Cvoid}
    ctx::CUcontext
    pRangeName::Cstring
    rangeNameLength::Csize_t
end

struct CUpti_Profiler_PopRange_Params
    structSize::Csize_t
    pPriv::Ptr{Cvoid}
    ctx::CUcontext
end

struct CUpti_Profiler_GetCounterAvailability_Params
    structSize::Csize_t
    pPriv::Ptr{Cvoid}
    ctx::CUcontext
    counterAvailabilityImageSize::Csize_t
    pCounterAvailabilityImage::Ptr{UInt8}
end

@cenum CUpti_Profiler_Support_Level::UInt32 begin
    CUPTI_PROFILER_CONFIGURATION_UNKNOWN = 0
    CUPTI_PROFILER_CONFIGURATION_UNSUPPORTED = 1
    CUPTI_PROFILER_CONFIGURATION_DISABLED = 2
    CUPTI_PROFILER_CONFIGURATION_SUPPORTED = 3
end

struct CUpti_Profiler_DeviceSupported_Params
    structSize::Csize_t
    pPriv::Ptr{Cvoid}
    cuDevice::CUdevice
    isSupported::CUpti_Profiler_Support_Level
    architecture::CUpti_Profiler_Support_Level
    sli::CUpti_Profiler_Support_Level
    vGpu::CUpti_Profiler_Support_Level
    confidentialCompute::CUpti_Profiler_Support_Level
    cmp::CUpti_Profiler_Support_Level
end

@checked function cuptiProfilerInitialize(pParams)
    initialize_context()
    @ccall libcupti.cuptiProfilerInitialize(pParams::Ptr{CUpti_Profiler_Initialize_Params})::CUptiResult
end

@checked function cuptiProfilerDeInitialize(pParams)
    initialize_context()
    @ccall libcupti.cuptiProfilerDeInitialize(pParams::Ptr{CUpti_Profiler_DeInitialize_Params})::CUptiResult
end

@checked function cuptiProfilerCounterDataImageCalculateSize(pParams)
    initialize_context()
    @ccall libcupti.cuptiProfilerCounterDataImageCalculateSize(pParams::Ptr{CUpti_Profiler_CounterDataImage_CalculateSize_Params})::CUptiResult
end

@checked function cuptiProfilerCounterDataImageInitialize(pParams)
    initialize_context()
    @ccall libcupti.cuptiProfilerCounterDataImageInitialize(pParams::Ptr{CUpti_Profiler_CounterDataImage_Initialize_Params})::CUptiResult
end

@checked function cuptiProfilerCounterDataImageCalculateScratchBufferSize(pParams)
    initialize_context()
    @ccall libcupti.cuptiProfilerCounterDataImageCalculateScratchBufferSize(pParams::Ptr{CUpti_Profiler_CounterDataImage_CalculateScratchBufferSize_Params})::CUptiResult
end

@checked function cuptiProfilerCounterDataImageInitializeScratchBuffer(pParams)
    initialize_context()
    @ccall libcupti.cuptiProfilerCounterDataImageInitializeScratchBuffer(pParams::Ptr{CUpti_Profiler_CounterDataImage_InitializeScratchBuffer_Params})::CUptiResult
end

@checked function cuptiProfilerBeginSession(pParams)
    initialize_context()
    @ccall libcupti.cuptiProfilerBeginSession(pParams::Ptr{CUpti_Profiler_BeginSession_Params})::CUptiResult
end

@checked function cuptiProfilerEndSession(pParams)
    initialize_context()
    @ccall libcupti.cuptiProfilerEndSession(pParams::Ptr{CUpti_Profiler_EndSession_Params})::CUptiResult
end

@checked function cuptiProfilerSetConfig(pParams)
    initialize_context()
    @ccall libcupti.cuptiProfilerSetConfig(pParams::Ptr{CUpti_Profiler_SetConfig_Params})::CUptiResult
end

@checked function cuptiProfilerUnsetConfig(pParams)
    initialize_context()
    @ccall libcupti.cuptiProfilerUnsetConfig(pParams::Ptr{CUpti_Profiler_UnsetConfig_Params})::CUptiResult
end

@checked function cuptiProfilerBeginPass(pParams)
    initialize_context()
    @ccall libcupti.cuptiProfilerBeginPass(pParams::Ptr{CUpti_Profiler_BeginPass_Params})::CUptiResult
end

@checked function cuptiProfilerEndPass(pParams)
    initialize_context()
    @ccall libcupti.cuptiProfilerEndPass(pParams::Ptr{CUpti_Profiler_EndPass_Params})::CUptiResult
end

@checked function cuptiProfilerEnableProfiling(pParams)
    initialize_context()
    @ccall libcupti.cuptiProfilerEnableProfiling(pParams::Ptr{CUpti_Profiler_EnableProfiling_Params})::CUptiResult
end

@checked function cuptiProfilerDisableProfiling(pParams)
    initialize_context()
    @ccall libcupti.cuptiProfilerDisableProfiling(pParams::Ptr{CUpti_Profiler_DisableProfiling_Params})::CUptiResult
end

@checked function cuptiProfilerIsPassCollected(pParams)
    initialize_context()
    @ccall libcupti.cuptiProfilerIsPassCollected(pParams::Ptr{CUpti_Profiler_IsPassCollected_Params})::CUptiResult
end

@checked function cuptiProfilerFlushCounterData(pParams)
    initialize_context()
    @ccall libcupti.cuptiProfilerFlushCounterData(pParams::Ptr{CUpti_Profiler_FlushCounterData_Params})::CUptiResult
end

@checked function cuptiProfilerPushRange(pParams)
    initialize_context()
    @ccall libcupti.cuptiProfilerPushRange(pParams::Ptr{CUpti_Profiler_PushRange_Params})::CUptiResult
end

@checked function cuptiProfilerPopRange(pParams)
    initialize_context()
    @ccall libcupti.cuptiProfilerPopRange(pParams::Ptr{CUpti_Profiler_PopRange_Params})::CUptiResult
end

@checked function cuptiProfilerGetCounterAvailability(pParams)
    initialize_context()
    @ccall libcupti.cuptiProfilerGetCounterAvailability(pParams::Ptr{CUpti_Profiler_GetCounterAvailability_Params})::CUptiResult
end

@checked function cuptiProfilerDeviceSupported(pParams)
    initialize_context()
    @ccall libcupti.cuptiProfilerDeviceSupported(pParams::Ptr{CUpti_Profiler_DeviceSupported_Params})::CUptiResult
end

struct var"##Ctag#705"
    processId::UInt32
    threadId::UInt32
end
function Base.getproperty(x::Ptr{var"##Ctag#705"}, f::Symbol)
    f === :processId && return Ptr{UInt32}(x + 0)
    f === :threadId && return Ptr{UInt32}(x + 4)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#705", f::Symbol)
    r = Ref{var"##Ctag#705"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#705"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#705"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#706"
    deviceId::UInt32
    contextId::UInt32
    streamId::UInt32
end
function Base.getproperty(x::Ptr{var"##Ctag#706"}, f::Symbol)
    f === :deviceId && return Ptr{UInt32}(x + 0)
    f === :contextId && return Ptr{UInt32}(x + 4)
    f === :streamId && return Ptr{UInt32}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#706", f::Symbol)
    r = Ref{var"##Ctag#706"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#706"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#706"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#708"
    index::UInt32
    domainId::UInt32
end
function Base.getproperty(x::Ptr{var"##Ctag#708"}, f::Symbol)
    f === :index && return Ptr{UInt32}(x + 0)
    f === :domainId && return Ptr{UInt32}(x + 4)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#708", f::Symbol)
    r = Ref{var"##Ctag#708"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#708"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#708"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#710"
    index::UInt32
    domainId::UInt32
end
function Base.getproperty(x::Ptr{var"##Ctag#710"}, f::Symbol)
    f === :index && return Ptr{UInt32}(x + 0)
    f === :domainId && return Ptr{UInt32}(x + 4)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#710", f::Symbol)
    r = Ref{var"##Ctag#710"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#710"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#710"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#719"
    requested::UInt8
    executed::UInt8
end
function Base.getproperty(x::Ptr{var"##Ctag#719"}, f::Symbol)
    f === :requested && return (Ptr{UInt8}(x + 0), 0, 4)
    f === :executed && return (Ptr{UInt8}(x + 0), 4, 4)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#719", f::Symbol)
    r = Ref{var"##Ctag#719"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#719"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#719"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#721"
    smClock::UInt32
    memoryClock::UInt32
    pcieLinkGen::UInt32
    pcieLinkWidth::UInt32
    clocksThrottleReasons::CUpti_EnvironmentClocksThrottleReason
end
function Base.getproperty(x::Ptr{var"##Ctag#721"}, f::Symbol)
    f === :smClock && return Ptr{UInt32}(x + 0)
    f === :memoryClock && return Ptr{UInt32}(x + 4)
    f === :pcieLinkGen && return Ptr{UInt32}(x + 8)
    f === :pcieLinkWidth && return Ptr{UInt32}(x + 12)
    f === :clocksThrottleReasons &&
        return Ptr{CUpti_EnvironmentClocksThrottleReason}(x + 16)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#721", f::Symbol)
    r = Ref{var"##Ctag#721"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#721"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#721"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#722"
    gpuTemperature::UInt32
end
function Base.getproperty(x::Ptr{var"##Ctag#722"}, f::Symbol)
    f === :gpuTemperature && return Ptr{UInt32}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#722", f::Symbol)
    r = Ref{var"##Ctag#722"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#722"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#722"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#723"
    power::UInt32
    powerLimit::UInt32
end
function Base.getproperty(x::Ptr{var"##Ctag#723"}, f::Symbol)
    f === :power && return Ptr{UInt32}(x + 0)
    f === :powerLimit && return Ptr{UInt32}(x + 4)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#723", f::Symbol)
    r = Ref{var"##Ctag#723"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#723"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#723"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#724"
    fanSpeed::UInt32
end
function Base.getproperty(x::Ptr{var"##Ctag#724"}, f::Symbol)
    f === :fanSpeed && return Ptr{UInt32}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#724", f::Symbol)
    r = Ref{var"##Ctag#724"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#724"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#724"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#726"
    requested::UInt8
    executed::UInt8
end
function Base.getproperty(x::Ptr{var"##Ctag#726"}, f::Symbol)
    f === :requested && return (Ptr{UInt8}(x + 0), 0, 4)
    f === :executed && return (Ptr{UInt8}(x + 0), 4, 4)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#726", f::Symbol)
    r = Ref{var"##Ctag#726"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#726"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#726"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#730"
    index::UInt32
    domainId::UInt32
end
function Base.getproperty(x::Ptr{var"##Ctag#730"}, f::Symbol)
    f === :index && return Ptr{UInt32}(x + 0)
    f === :domainId && return Ptr{UInt32}(x + 4)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#730", f::Symbol)
    r = Ref{var"##Ctag#730"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#730"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#730"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#732"
    index::UInt32
    domainId::UInt32
end
function Base.getproperty(x::Ptr{var"##Ctag#732"}, f::Symbol)
    f === :index && return Ptr{UInt32}(x + 0)
    f === :domainId && return Ptr{UInt32}(x + 4)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#732", f::Symbol)
    r = Ref{var"##Ctag#732"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#732"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#732"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#734"
    requested::UInt8
    executed::UInt8
end
function Base.getproperty(x::Ptr{var"##Ctag#734"}, f::Symbol)
    f === :requested && return (Ptr{UInt8}(x + 0), 0, 4)
    f === :executed && return (Ptr{UInt8}(x + 0), 4, 4)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#734", f::Symbol)
    r = Ref{var"##Ctag#734"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#734"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#734"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#736"
    requested::UInt8
    executed::UInt8
end
function Base.getproperty(x::Ptr{var"##Ctag#736"}, f::Symbol)
    f === :requested && return (Ptr{UInt8}(x + 0), 0, 4)
    f === :executed && return (Ptr{UInt8}(x + 0), 4, 4)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#736", f::Symbol)
    r = Ref{var"##Ctag#736"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#736"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#736"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#761"
    requested::UInt8
    executed::UInt8
end
function Base.getproperty(x::Ptr{var"##Ctag#761"}, f::Symbol)
    f === :requested && return (Ptr{UInt8}(x + 0), 0, 4)
    f === :executed && return (Ptr{UInt8}(x + 0), 4, 4)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#761", f::Symbol)
    r = Ref{var"##Ctag#761"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#761"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#761"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#763"
    requested::UInt8
    executed::UInt8
end
function Base.getproperty(x::Ptr{var"##Ctag#763"}, f::Symbol)
    f === :requested && return (Ptr{UInt8}(x + 0), 0, 4)
    f === :executed && return (Ptr{UInt8}(x + 0), 4, 4)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#763", f::Symbol)
    r = Ref{var"##Ctag#763"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#763"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#763"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#766"
    index::UInt32
    domainId::UInt32
end
function Base.getproperty(x::Ptr{var"##Ctag#766"}, f::Symbol)
    f === :index && return Ptr{UInt32}(x + 0)
    f === :domainId && return Ptr{UInt32}(x + 4)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#766", f::Symbol)
    r = Ref{var"##Ctag#766"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#766"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#766"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#768"
    index::UInt32
    domainId::UInt32
end
function Base.getproperty(x::Ptr{var"##Ctag#768"}, f::Symbol)
    f === :index && return Ptr{UInt32}(x + 0)
    f === :domainId && return Ptr{UInt32}(x + 4)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#768", f::Symbol)
    r = Ref{var"##Ctag#768"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#768"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#768"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#770"
    requested::UInt8
    executed::UInt8
end
function Base.getproperty(x::Ptr{var"##Ctag#770"}, f::Symbol)
    f === :requested && return (Ptr{UInt8}(x + 0), 0, 4)
    f === :executed && return (Ptr{UInt8}(x + 0), 4, 4)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#770", f::Symbol)
    r = Ref{var"##Ctag#770"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#770"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#770"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#781"
    uuidDev::CUuuid
    peerDev::NTuple{32,CUdevice}
end
function Base.getproperty(x::Ptr{var"##Ctag#781"}, f::Symbol)
    f === :uuidDev && return Ptr{CUuuid}(x + 0)
    f === :peerDev && return Ptr{NTuple{32,CUdevice}}(x + 16)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#781", f::Symbol)
    r = Ref{var"##Ctag#781"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#781"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#781"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#782"
    secondaryBus::UInt16
    deviceId::UInt16
    vendorId::UInt16
    pad0::UInt16
end
function Base.getproperty(x::Ptr{var"##Ctag#782"}, f::Symbol)
    f === :secondaryBus && return Ptr{UInt16}(x + 0)
    f === :deviceId && return Ptr{UInt16}(x + 2)
    f === :vendorId && return Ptr{UInt16}(x + 4)
    f === :pad0 && return Ptr{UInt16}(x + 6)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#782", f::Symbol)
    r = Ref{var"##Ctag#782"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#782"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#782"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#785"
    index::UInt32
    domainId::UInt32
end
function Base.getproperty(x::Ptr{var"##Ctag#785"}, f::Symbol)
    f === :index && return Ptr{UInt32}(x + 0)
    f === :domainId && return Ptr{UInt32}(x + 4)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#785", f::Symbol)
    r = Ref{var"##Ctag#785"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#785"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#785"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#787"
    index::UInt32
    domainId::UInt32
end
function Base.getproperty(x::Ptr{var"##Ctag#787"}, f::Symbol)
    f === :index && return Ptr{UInt32}(x + 0)
    f === :domainId && return Ptr{UInt32}(x + 4)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#787", f::Symbol)
    r = Ref{var"##Ctag#787"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#787"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#787"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#796"
    requested::UInt8
    executed::UInt8
end
function Base.getproperty(x::Ptr{var"##Ctag#796"}, f::Symbol)
    f === :requested && return (Ptr{UInt8}(x + 0), 0, 4)
    f === :executed && return (Ptr{UInt8}(x + 0), 4, 4)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#796", f::Symbol)
    r = Ref{var"##Ctag#796"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#796"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#796"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

const CUPTI_EVENT_OVERFLOW = uint64_t(Culonglong(0xffffffffffffffff))

const CUPTI_EVENT_INVALID = uint64_t(Culonglong(0xfffffffffffffffe))

const CUPTILP64 = 1

const ACTIVITY_RECORD_ALIGNMENT = 8

# Skipping MacroDefinition: PACKED_ALIGNMENT __attribute__ ( ( __packed__ ) ) __attribute__ ( ( aligned ( ACTIVITY_RECORD_ALIGNMENT ) ) )

const CUPTI_UNIFIED_MEMORY_CPU_DEVICE_ID = uint32_t(Cuint(0xffffffff))

const CUPTI_INVALID_CONTEXT_ID = uint32_t(Cuint(0xffffffff))

const CUPTI_INVALID_STREAM_ID = uint32_t(Cuint(0xffffffff))

const CUPTI_INVALID_CHANNEL_ID = uint32_t(Cuint(0xffffffff))

const CUPTI_SOURCE_LOCATOR_ID_UNKNOWN = 0

const CUPTI_FUNCTION_INDEX_ID_INVALID = 0

const CUPTI_CORRELATION_ID_UNKNOWN = 0

const CUPTI_GRID_ID_UNKNOWN = Clonglong(0)

const CUPTI_TIMESTAMP_UNKNOWN = Clonglong(0)

const CUPTI_SYNCHRONIZATION_INVALID_VALUE = -1

const CUPTI_AUTO_BOOST_INVALID_CLIENT_PID = 0

const CUPTI_NVLINK_INVALID_PORT = -1

const CUPTI_MAX_NVLINK_PORTS = 32

const CUPTI_MAX_GPUS = 32