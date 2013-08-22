"""
"""

import os

from stdlib cimport malloc, free


__version__ = '0.1'
AT_A_TIME = 25000


cdef extern from "Python.h":
    ctypedef struct PyObject
    PyObject *PyExc_IOError
    object PyErr_SetFromErrno(PyObject *)


cdef extern from 'sys/ioctl.h':
    int ioctl(int d, int request, ...) nogil


cdef extern from 'sys/types.h':
    ctypedef unsigned long time_t


cdef extern from 'sys/stat.h':
    int S_ISREG(int mode)
    int S_ISDIR(int mode)
    int S_ISFIFO(int mode)
    int S_ISLNK(int mode)


cdef extern from 'xfs/xfs.h':
    struct xfs_bstime_t:
        time_t tv_sec
        int tv_nsec
    struct xfs_bstat:
        int bs_mode
        int bs_size
        int bs_xflags
        int bs_ino
        int bs_rdev
        int bs_nlink
        int bs_uid
        int bs_gid
        xfs_bstime_t bs_atime
        xfs_bstime_t bs_mtime
        xfs_bstime_t bs_ctime
    struct xfs_fsop_bulkreq:
        unsigned long long int *lastip
        int icount
        xfs_bstat *ubuffer
        int *ocount
    int XFS_IOC_FSBULKSTAT
    int _XFS_XFLAG_HASATTR "XFS_XFLAG_HASATTR", \
        _XFS_XFLAG_REALTIME "XFS_XFLAG_REALTIME", \
        _XFS_XFLAG_PREALLOC "XFS_XFLAG_PREALLOC", \
        _XFS_XFLAG_IMMUTABLE "XFS_XFLAG_IMMUTABLE", \
        _XFS_XFLAG_APPEND "XFS_XFLAG_APPEND", \
        _XFS_XFLAG_SYNC "XFS_XFLAG_SYNC", \
        _XFS_XFLAG_NOATIME "XFS_XFLAG_NOATIME", \
        _XFS_XFLAG_NODUMP "XFS_XFLAG_NODUMP", \
        _XFS_XFLAG_RTINHERIT "XFS_XFLAG_RTINHERIT", \
        _XFS_XFLAG_PROJINHERIT "XFS_XFLAG_PROJINHERIT", \
        _XFS_XFLAG_NOSYMLINKS "XFS_XFLAG_NOSYMLINKS", \
        _XFS_XFLAG_EXTSIZE "XFS_XFLAG_EXTSIZE", \
        _XFS_XFLAG_EXTSZINHERIT "XFS_XFLAG_EXTSZINHERIT", \
        _XFS_XFLAG_NODEFRAG "XFS_XFLAG_NODEFRAG", \
        _XFS_XFLAG_FILESTREAM "XFS_XFLAG_FILESTREAM", \
        _XFS_XFLAG_HASATTR "XFS_XFLAG_HASATTR"


XFS_XFLAG_HASATTR = _XFS_XFLAG_HASATTR
XFS_XFLAG_REALTIME = _XFS_XFLAG_REALTIME
XFS_XFLAG_PREALLOC = _XFS_XFLAG_PREALLOC
XFS_XFLAG_IMMUTABLE = _XFS_XFLAG_IMMUTABLE
XFS_XFLAG_APPEND = _XFS_XFLAG_APPEND
XFS_XFLAG_SYNC = _XFS_XFLAG_SYNC
XFS_XFLAG_NOATIME = _XFS_XFLAG_NOATIME
XFS_XFLAG_NODUMP = _XFS_XFLAG_NODUMP
XFS_XFLAG_RTINHERIT = _XFS_XFLAG_RTINHERIT
XFS_XFLAG_PROJINHERIT = _XFS_XFLAG_PROJINHERIT
XFS_XFLAG_NOSYMLINKS = _XFS_XFLAG_NOSYMLINKS
XFS_XFLAG_EXTSIZE = _XFS_XFLAG_EXTSIZE
XFS_XFLAG_EXTSZINHERIT = _XFS_XFLAG_EXTSZINHERIT
XFS_XFLAG_NODEFRAG = _XFS_XFLAG_NODEFRAG
XFS_XFLAG_FILESTREAM = _XFS_XFLAG_FILESTREAM
XFS_XFLAG_HASATTR = _XFS_XFLAG_HASATTR


cdef extern from 'xfs/jdm.h':
    ctypedef struct jdm_filehandle_t
    ctypedef struct jdm_fshandle_t
    jdm_fshandle_t *jdm_getfshandle(char *mntpnt)
    int jdm_open(jdm_fshandle_t *fshandlep, xfs_bstat *sp, int oflags)


cdef class open_bstat:
    cdef xfs_bstat *stat
    cdef jdm_fshandle_t *fs
    cdef int fd

    def __enter__(self):
        self.fd = jdm_open(self.fs, self.stat, os.O_RDONLY)
        if self.fd < 0:
            return PyErr_SetFromErrno(PyExc_IOError)
        return self.fd

    def __exit__(self, typ, value, traceback):
        os.close(self.fd)


cdef class bstat:
    cdef xfs_bstat *stat
    cdef jdm_fshandle_t *fs

    @property
    def st_size(self):
        return self.stat.bs_size

    @property
    def st_mode(self):
        return self.stat.bs_mode

    @property
    def st_ino(self):
        return self.stat.bs_ino

    @property
    def st_dev(self):
        return self.stat.bs_rdev

    @property
    def st_nlink(self):
        return self.stat.bs_nlink

    @property
    def st_uid(self):
        return self.stat.bs_uid

    @property
    def st_gid(self):
        return self.stat.bs_gid

    @property
    def st_atime(self):
        return self.stat.bs_atime.tv_sec

    @property
    def st_mtime(self):
        return self.stat.bs_mtime.tv_sec

    @property
    def st_ctime(self):
        return self.stat.bs_ctime.tv_sec

    @property
    def st_fatime(self):
        return self.stat.bs_atime.tv_sec + (self.stat.bs_atime.tv_nsec /
                                            1000000000.0)

    @property
    def st_fmtime(self):
        return self.stat.bs_mtime.tv_sec + (self.stat.bs_mtime.tv_nsec /
                                            1000000000.0)

    @property
    def st_fctime(self):
        return self.stat.bs_ctime.tv_sec + (self.stat.bs_ctime.tv_nsec /
                                            1000000000.0)

    @property
    def st_xflags(self):
        return self.stat.bs_xflags

    def has_xattrs(self):
        return self.stat.bs_xflags & _XFS_XFLAG_HASATTR

    def isreg(self):
        return S_ISREG(self.stat.bs_mode)

    def isdir(self):
        return S_ISDIR(self.stat.bs_mode)

    def isfifo(self):
        return S_ISFIFO(self.stat.bs_mode)

    def islink(self):
        return S_ISLNK(self.stat.bs_mode)

    def open(self):
        cdef open_bstat filectx = open_bstat()
        filectx.stat = self.stat
        filectx.fs = self.fs
        return filectx

    def __repr__(self):
        return ('bstat(st_mode=%s, st_ino=%s, st_dev=%s, st_nlink=%s, '
                'st_uid=%s, st_gid=%s, st_size=%s, st_atime=%s, '
                'st_mtime=%s, st_ctime=%s)' %
                (self.st_mode, self.st_ino, self.st_dev, self.st_nlink,
                 self.st_uid, self.st_gid, self.st_size, self.st_atime,
                 self.st_mtime, self.st_ctime))


cdef class BulkstatResult:
    cdef bstat stat
    cdef int count
    cdef unsigned long long int last
    cdef xfs_bstat *t
    cdef xfs_fsop_bulkreq bsr
    cdef jdm_fshandle_t *fs
    cdef int fd
    cdef int done
    cdef int pos

    def __init__(self, path):
        self.fd = os.open(path, os.O_DIRECTORY)
        if self.fd < 0:
            PyErr_SetFromErrno(PyExc_IOError)
            return
        self.fs = jdm_getfshandle(path)
        if not self.fs:
            raise Exception('Unable to get filesystem handle')
        self.t = <xfs_bstat *>malloc(AT_A_TIME * sizeof(xfs_bstat))
        if not self.t:
            raise Exception('Unable to allocate stat buffer')
        self.stat = bstat()
        self.stat.fs = self.fs
        self.count = 0
        self.last = 0
        self.pos = 0
        self.bsr.lastip = &self.last
        self.bsr.icount = AT_A_TIME
        self.bsr.ubuffer = self.t
        self.bsr.ocount = &self.count

    def __dealloc__(self):
        if self.fd >= 0:
            os.close(self.fd)
        if self.t:
            free(self.t)

    def __iter__(self):
        return self

    def __next__(self):
        cdef int ioctl_result
        if self.pos >= self.count:
            with nogil:
                ioctl_result = ioctl(self.fd, XFS_IOC_FSBULKSTAT, &self.bsr)
            if ioctl_result != 0:
                return PyErr_SetFromErrno(PyExc_IOError)
            if self.count == 0:
                raise StopIteration()
            self.pos = 0
        self.stat.stat = &self.t[self.pos]
        self.pos += 1
        return self.stat


def bulkstat(path):
    """
    bulkstat(fs_path)

    Returns an iterator of stat-like objects for inodes in the filesystem.

    Stat-like objects have the same properties as stat results: st_size,
    st_ino, st_mode, st_dev, st_nlink, st_uid, st_gid, st_atime, st_ctime,
    st_mtime

    They also contain:

    st_fatime, st_fctime, st_fmtime properties: same as st_atime, st_ctime and
        st_mtime, except a float including subseconds

    st_xflags property: xfs extended attributes

    has_xattrs() method: returns true if the file contains extended attributes.

    isreg(), isdir(), isfifo(), islink(): convenience methods for identifying
        file type by mode.

    open() method: contextmanager that returns a read-only file descriptor
    """
    return BulkstatResult(path)

