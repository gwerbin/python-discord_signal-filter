# cython: language_level=3

import cython
import numpy as np
cimport numpy as np

ctypedef np.float_t DTYPE_t
DTYPE = np.float

@cython.boundscheck(False)
cdef int _process_chunk(
            np.ndarray[DTYPE_t, ndim=1, mode='c'] signal,
            np.ndarray[DTYPE_t, ndim=1, mode='c'] new_signal,
            np.ndarray[DTYPE_t, ndim=1, mode='c'] prev_buffer,
            Py_ssize_t n,
            Py_ssize_t window_size
        ) except -1:
    """ Process a chunk of the signal

    NO DATA VALIDATION IS DONE.

    Assumption:
        assert len(signal) == chunk_size
        assert len(signal) == len(new_signal)
        assert len(signal) == n
        assert len(prev_buffer) == window_size
    """
    cdef Py_ssize_t i
    cdef Py_ssize_t ii
    cdef float np1 = n + 1
    cdef float x

    for i in range(n):
        x = 0

        for ii in range(window_size):
            if ii + i >= window_size:
                x += signal[ii + i]
            else:
                x += prev_buffer[ii + i]

        new_signal[i] = (x + signal[i]) / np1

    prev_buffer[:] = signal[-window_size:]

    return 0


@cython.boundscheck(False)
def filter_signal(chunks, int chunk_size):
    """ Process signal in chunks

    Example usage:

        def get_chunks(signal_reader, n):
            while True:
                chunk = signal_reader.read(n)  # fictitious API just to demonstrate lazily reading some data
                if not chunk:
                    break
                yield chunk

        chunksize = 1024
        processed_chunks = []
        signal_chunks = get_chunks(signal_reader, chunksize)
        for i, new_chunk in enumerate(process_chunks(signal_chunks, chunksize))):
            print(f'Processing chunk {i}')
            processed_chunks.append(new_chunk)

        processed_signal = np.concatenate(processed_chunks)

    Note that it would be slightly more efficient to write:

        processed_signal = np.concatenate(list(process_chunks(signal_chunks, chunksize)))
    """
    chunk_buffer = np.zeros(chunk_size, dtype=DTYPE)

    for chunk in chunks:
        chunk_size = chunk.shape[0]
        new_chunk = np.empty(chunk_size)

        err = _process_chunk(chunk, new_chunk, chunk_buffer, chunk_size, chunk_size)
        if err == -1:
            raise RuntimeError('Error in chunk processing')

        yield new_chunk

