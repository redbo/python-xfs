This will be a set of modules for working with XFS filesystems.  It will bind xfslibs APIs in a pythonic manner.

Currently, the only API implemented is bulkstat.

bulkstat(mountpoint)

    Returns an iterator of stat-like objects for inodes in the filesystem.  The stat-like objects have the same properties as stat results: `st_size`, `st_ino`, `st_mode`, `st_dev`, `st_nlink`, `st_uid`, `st_gid`, `st_atime`, `st_ctime`, and `st_mtime`

    They also contain:

    `st_fatime`, `st_fctime`, `st_fmtime`: same as `st_atime`, `st_ctime` and `st_mtime`, except they return a float including subseconds, similar to `time.time()`

    `st_xflags`: xfs extended flags

    `has_xattrs()`: returns true if the file contains extended attributes.

    `isreg()`, `isdir()`, `isfifo()`, `islink()`: convenience methods for identifying file type by mode.

    `open()`: contextmanager that returns a read-only file descriptor for the file

Defined constants:

    `XFS_XFLAG_HASATTR`, `XFS_XFLAG_REALTIME`, `XFS_XFLAG_PREALLOC`, `XFS_XFLAG_IMMUTABLE`, `XFS_XFLAG_APPEND`, `XFS_XFLAG_SYNC`, `XFS_XFLAG_NOATIME`, `XFS_XFLAG_NODUMP`, `XFS_XFLAG_RTINHERIT`, `XFS_XFLAG_PROJINHERIT`, `XFS_XFLAG_NOSYMLINKS`, `XFS_XFLAG_EXTSIZE`, `XFS_XFLAG_EXTSZINHERIT`, `XFS_XFLAG_NODEFRAG`, `XFS_XFLAG_FILESTREAM`, `XFS_XFLAG_HASATTR`
