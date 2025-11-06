import React, { useState, useEffect } from 'react';
import { Box, Typography, IconButton, Dialog, DialogActions, DialogContent, DialogTitle, Button, TextField, Checkbox, FormControlLabel } from '@mui/material';
import { DataGrid } from '@mui/x-data-grid';
import dataService from '../services/dataService';
import DeleteIcon from '@mui/icons-material/Delete';
import EditIcon from '@mui/icons-material/Edit';
import AddIcon from '@mui/icons-material/Add';

const ParkingZonesPage = () => {
  const [parkingZones, setParkingZones] = useState([]);
  const [loading, setLoading] = useState(true);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [zoneToDelete, setZoneToDelete] = useState(null);
  const [formDialogOpen, setFormDialogOpen] = useState(false);
  const [currentZone, setCurrentZone] = useState(null);

  const fetchParkingZones = () => {
    setLoading(true);
    dataService.getAll('parking-zones')
      .then(response => {
        setParkingZones(response.data);
        setLoading(false);
      })
      .catch(error => {
        console.error("Failed to fetch parking zones:", error);
        setLoading(false);
      });
  };

  useEffect(() => {
    fetchParkingZones();
  }, []);

  const handleOpenFormDialog = (zone = null) => {
    setCurrentZone(zone ? { ...zone } : { name: '', latitude: '', longitude: '', radius: '', is_active: true });
    setFormDialogOpen(true);
  };

  const handleCloseFormDialog = () => {
    setFormDialogOpen(false);
    setCurrentZone(null);
  };

  const handleSave = async () => {
    try {
      if (currentZone.id) {
        await dataService.update('parking-zones', currentZone.id, currentZone);
      } else {
        await dataService.create('parking-zones', currentZone);
      }
      fetchParkingZones();
      handleCloseFormDialog();
    } catch (error) {
      console.error("Failed to save parking zone:", error);
    }
  };

  const handleDeleteClick = (id) => {
    setZoneToDelete(id);
    setDeleteDialogOpen(true);
  };

  const handleDeleteConfirm = async () => {
    try {
      await dataService.remove('parking-zones', zoneToDelete);
      fetchParkingZones();
      setDeleteDialogOpen(false);
      setZoneToDelete(null);
    } catch (error) {
      console.error("Failed to delete parking zone:", error);
    }
  };

  const columns = [
    { field: 'id', headerName: 'ID', width: 220 },
    { field: 'name', headerName: 'Name', width: 150 },
    { field: 'latitude', headerName: 'Latitude', type: 'number', width: 120 },
    { field: 'longitude', headerName: 'Longitude', type: 'number', width: 120 },
    { field: 'radius', headerName: 'Radius (m)', type: 'number', width: 100 },
    { field: 'is_active', headerName: 'Active', type: 'boolean', width: 100 },
    {
      field: 'actions',
      headerName: 'Actions',
      type: 'actions',
      width: 120,
      getActions: ({ id, row }) => [
        <IconButton color="primary" onClick={() => handleOpenFormDialog(row)}><EditIcon /></IconButton>,
        <IconButton color="error" onClick={() => handleDeleteClick(id)}><DeleteIcon /></IconButton>,
      ],
    },
  ];

  return (
    <Box sx={{ height: '85vh', width: '100%' }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
        <Typography variant="h4">Manage Parking Zones</Typography>
        <Button variant="contained" startIcon={<AddIcon />} onClick={() => handleOpenFormDialog()}>Create Zone</Button>
      </Box>
      <DataGrid
        rows={parkingZones}
        columns={columns}
        loading={loading}
        getRowId={(row) => row.id}
        initialState={{
          pagination: {
            paginationModel: { page: 0, pageSize: 10 },
          },
        }}
        pageSizeOptions={[5, 10, 20]}
        checkboxSelection
      />
      <Dialog open={deleteDialogOpen} onClose={() => setDeleteDialogOpen(false)}>
        <DialogTitle>Confirm Deletion</DialogTitle>
        <DialogContent><p>Are you sure you want to delete this parking zone?</p></DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteDialogOpen(false)}>Cancel</Button>
          <Button onClick={handleDeleteConfirm} color="error">Delete</Button>
        </DialogActions>
      </Dialog>
      <Dialog open={formDialogOpen} onClose={handleCloseFormDialog}>
        <DialogTitle>{currentZone?.id ? 'Edit Zone' : 'Create Zone'}</DialogTitle>
        <DialogContent>
            {currentZone && (
                <Box component="form" sx={{ mt: 2 }}>
                    <TextField margin="dense" label="Name" fullWidth value={currentZone.name} onChange={(e) => setCurrentZone({ ...currentZone, name: e.target.value })} />
                    <TextField margin="dense" label="Latitude" type="number" fullWidth value={currentZone.latitude} onChange={(e) => setCurrentZone({ ...currentZone, latitude: e.target.value })} />
                    <TextField margin="dense" label="Longitude" type="number" fullWidth value={currentZone.longitude} onChange={(e) => setCurrentZone({ ...currentZone, longitude: e.target.value })} />
                    <TextField margin="dense" label="Radius (m)" type="number" fullWidth value={currentZone.radius} onChange={(e) => setCurrentZone({ ...currentZone, radius: e.target.value })} />
                    <FormControlLabel control={<Checkbox checked={currentZone.is_active} onChange={(e) => setCurrentZone({ ...currentZone, is_active: e.target.checked })} />} label="Active" />
                </Box>
            )}
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseFormDialog}>Cancel</Button>
          <Button onClick={handleSave}>Save</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default ParkingZonesPage;