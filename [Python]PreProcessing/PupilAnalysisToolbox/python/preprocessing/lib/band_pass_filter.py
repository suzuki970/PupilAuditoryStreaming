
from scipy import signal

def butter_bandpass(lowcut, highcut, fs, order=4):
    nyq = 0.5 * fs
    low = lowcut / nyq
    high = highcut / nyq
    b, a = signal.butter(order, [low, high], btype='band')
    return b, a


def butter_bandpass_filter(data, lowcut, highcut, fs, order=4):
    b, a = butter_bandpass(lowcut, highcut, fs, order=order)
    y = signal.filtfilt(b, a, data)
    return y

def lowpass_filter(data, interval):

    n = data.shape[1]  # data length
    dt = interval/n    # sampling interval
    fn = 1/(2*dt)      # Nyquist frequency

    fp = 2                         # pass frequency[Hz]
    fs = 40                          # stop frequency[Hz]
    gpass = 1                       # 通過域最大損失量[dB]
    gstop = 40                      # 阻止域最小減衰量[dB]
    # normalization
    Wp = fp/fn
    Ws = fs/fn

    N, Wn = signal.buttord(Wp, Ws, gpass, gstop)
    b1, a1 = signal.butter(N, Wn, "low")
    y = signal.filtfilt(b1, a1, data)
    
    return y

# lowcut = 0.001
# highcut = 40
# data_filt = butter_bandpass_filter(dat[0,], lowcut, highcut, 500, order=4)


# dat = mat['pupilDataAll'] 
# # ave = np.mean(dat[0,])
# plt.plot(mat['pupilDataAll'][0,])
# fx = np.diff(mat['pupilDataAll'][0,])
# ind = np.argwhere(abs(fx) > 7.5).reshape(-1)
# dat[0,ind] = 0
# y = zeroInterp(dat[0,],5)

# pupilData=dat[0,]

# # plt.plot()
# plt.plot(y)
# plt.plot(dat[0,])
# plt.plot(data_filt+ave)
# plt.ylim([4000,5000])
# plt.ylim([2000,8000])

