================
Language Reference
================

This section provides comprehensive documentation for the Frame v0.20 programming language, including grammar, migration guides, and syntax references.

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   grammar
   migration_v0.11_to_v0.20

Quick Links
===========

**For New Users:**
- :doc:`../getting_started/index` - Start here for Frame basics
- :doc:`grammar` - Complete v0.20 grammar specification

**For Existing Users:**
- :doc:`migration_v0.11_to_v0.20` - Upgrade from v0.11 to v0.20
- :doc:`../intermediate_frame/index` - Advanced Frame features

Frame v0.20 Overview
====================

Frame v0.20 introduces significant syntax improvements to make the language more conventional and familiar to developers from mainstream programming languages while preserving Frame's unique state machine capabilities.

**Major Changes in v0.20:**

- **Modern Syntax**: Conventional ``system Name { }`` declarations
- **Standard Parameters**: Parentheses ``()`` instead of brackets ``[]``
- **Function-style Events**: ``eventName()`` instead of ``|eventName|``
- **Return Statements**: ``return`` keyword instead of ``^`` token
- **Control Flow**: Native ``if/elif/else`` and loop statements
- **Parent Dispatch**: ``=> $^`` statement syntax
- **Python Attributes**: ``@staticmethod`` instead of ``#[static]``

**Implementation Status:**

✅ **100% Test Coverage**: All v0.20 features validated with 98/98 tests passing  
✅ **Production Ready**: Complete transpiler implementation  
✅ **Comprehensive Documentation**: Grammar, examples, and migration guides  

Getting Help
============

- **Grammar Questions**: See :doc:`grammar` for complete BNF specification
- **Migration Issues**: Check :doc:`migration_v0.11_to_v0.20` for upgrade guidance  
- **Examples**: Browse the :doc:`../intermediate_frame/index` section for practical examples
- **Community**: Connect on `Discord <https://discord.com/invite/CfbU4QCbSD>`_
- **Issues**: Report bugs at `GitHub <https://github.com/frame-lang/frame_transpiler/issues>`_
