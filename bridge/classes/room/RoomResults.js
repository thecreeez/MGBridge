class RoomResults {
  /**
   * -1 - ERROR
   * 0  - SUCCESS
   */
  static HandshakeResult({ bSuccessfull = false, reason = "Unexpected reason", data } = {}) {
    if (!bSuccessfull) {
      return {
        code: -1,
        message: reason
      }
    }

    return {
      code: 0,
      data
    }
  }

  static UpdateResult({ bSuccessfull = false, reason = "Unexpected reason", data } = {}) {
    if (!bSuccessfull) {
      return {
        code: -1,
        message: reason
      }
    }

    return {
      code: 0,
      data
    }
  }
}

module.exports = RoomResults;