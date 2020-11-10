const API_URL = process.env.VUE_APP_API_URL

export const createPoll = (formData) => {
  return new Promise((resolve, reject) => {
    fetch(`${API_URL}/polls`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(formData),
    }).then((result) => {
      if (result.status === 400) {
        return reject("Sent data is invalid!");
      }

      resolve(result.json());
    });
  });
};

export const fetchPollResult = (id) => {
  return new Promise((resolve, reject) => {
    fetch(`${API_URL}/polls/${id}/results`).then((result) => {
      if (result.status === 400) {
        return reject("Invalid route!");
      } else if (result.status === 404) {
        return reject("Resource not found!");
      }
      resolve(result.json());
    });
  });
};

export const fetchPoll = (id) => {
  return new Promise((resolve, reject) => {
    fetch(`${API_URL}/polls/${id}`).then((result) => {
      if (result.status === 400) {
        return reject("Invalid route!");
      } else if (result.status === 404) {
        return reject("Resource not found!");
      }
      resolve(result.json());
    });
  });
};

export const getVoterIp = () => {
  return new Promise((resolve, reject) => {
    fetch("https://api.ipify.org?format=json")
      .then((result) => result.json())
      .then(({ ip }) => {
        resolve(ip);
      })
      .catch((error) => {
        reject(error);
      });
  });
};

export const castVote = (id, formData) => {
  return new Promise((resolve, reject) => {
    fetch(`${API_URL}/polls/${id}/vote`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(formData),
    }).then((result) => {
      if (result.status === 400) {
        return reject("Invalid route!");
      } else if (result.status === 404) {
        return reject("Resource not found!");
      }
      resolve();
    });
  });
};

export const checkVoteExist = (id, ip) => {
  return new Promise((resolve, reject) => {
    fetch(`${API_URL}/polls/${id}/vote_check?ip=${ip}`).then((result) => {
      if (result.status === 400) {
        return reject("Invalid route!");
      } else if (result.status === 404) {
        return reject("Resource not found!");
      }
      resolve(result.json());
    });
  });
};
