#
# Setup the a handler from SoapySDR log messages into Julia

function logger_soapy2jl(level, cmessage)
    message = unsafe_string(cmessage)
    if level == SOAPY_SDR_FATAL
        error(message)
    elseif level == SOAPY_SDR_CRITICAL
        @warn message
    else
        println("SoapySDR_jll: ", message)
    end
end
