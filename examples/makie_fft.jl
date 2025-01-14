using Revise
using SoapySDR
using GLMakie
using LinearAlgebra
using FFTW
using DSP

# Don't forget to add/import a device-specific plugin package!
# using xtrx_jll
# using SoapyLMS7_jll
using SoapyRTLSDR_jll
# using SoapyPlutoSDR_jll
# using SoapyUHD_jll

# Here we want to test the behavior in a loop, to ensure
# that we can block on buffer overflow conditions, and
# handle partial reads, measure latnecy, etc

freq = 104.3e6u"Hz"

function makie_viz(freq=freq)
    dev = open(Devices()[1])
    rx_chan = dev.rx[1]
    @show rx_chan
    rx_chan.gain_mode = true
    rx_chan.frequency = freq
    rx_stream = SoapySDR.Stream(ComplexF32, [rx_chan])
    @show rx_stream.mtu
    buf = Vector{ComplexF32}(undef, rx_stream.mtu)
    @show typeof(fft)
    sum = zeros(Float32, length(buf))
    norms = Observable(Vector{Float32}(undef,length(buf)))

    println("Makie Setup...")
    fig = Figure(); display(fig)
    ax = Axis(fig[1,1])
    xlims!(ax, 0, 100)
    ylims!(ax, -500, 500)
    lines!(ax, norms)

    h = Float32.(DSP.hamming(length(buf)))

    println("Starting fft loop..")
    Base.atexit(()->SoapySDR.deactivate!(rx_stream))

    SoapySDR.activate!(rx_stream)
    k = 1
    while true
        read!(rx_stream, (buf,))
        buf = fftshift(FFTW.fft!(buf.*h))
        norms[] .= (norm.(buf))
        #norms[] .= sum ./ k
        norms[] = norms[]
        println("fft") # makie needs a slight delay here
        k += 1
    end

end